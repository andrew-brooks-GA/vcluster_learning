#!/usr/bin/env bash
# scripts/latency-analyze.sh
# Parses .claude/latency.log and emits per-stage latency percentiles, retry
# distribution, FAIL rate, parent-side TTFT, and (when available) cache-hit rate.
#
# Usage:
#   bash scripts/latency-analyze.sh                       # analyze full log
#   bash scripts/latency-analyze.sh path/to/log           # analyze specific file
#   bash scripts/latency-analyze.sh path/to/log > out.txt # capture baseline

set -u

LOG="${1:-${CLAUDE_PROJECT_DIR:-.}/.claude/latency.log}"

if [ ! -f "$LOG" ]; then
  echo "ERROR: log file not found: $LOG" >&2
  exit 1
fi

# Single awk pass over the log. Pairs pre/post events by subagent type; any
# unmatched pre is treated as in-flight and excluded. Sequential reviewer pres
# without an intervening drafter pre count as retries.
awk '
function p50(arr, n,    i) {
  if (n == 0) return 0
  return arr[int((n+1)/2)]
}
function p95(arr, n,    i) {
  if (n == 0) return 0
  i = int(n * 0.95 + 0.5)
  if (i < 1) i = 1
  if (i > n) i = n
  return arr[i]
}
function pmax(arr, n) { return n == 0 ? 0 : arr[n] }
function asort_inplace(arr, n,    i, j, t) {
  for (i = 2; i <= n; i++) {
    t = arr[i]; j = i - 1
    while (j >= 1 && arr[j] > t) { arr[j+1] = arr[j]; j-- }
    arr[j+1] = t
  }
}
function summary(label, arr, n,    s, i, mean) {
  asort_inplace(arr, n)
  s = 0; for (i=1; i<=n; i++) s += arr[i]
  mean = 0
  if (n > 0) mean = s / n
  printf "  %-22s n=%-3d  p50=%5.2fs  p95=%5.2fs  max=%5.2fs  mean=%5.2fs\n", \
    label, n, p50(arr, n), p95(arr, n), pmax(arr, n), mean
}

{
  ts = $1 + 0
  phase = $2
  tool = $3
  agent = $4

  # Track per-subagent pre timestamps; emit duration on matching post.
  if (phase == "pre" && tool == "Agent") {
    pre[agent] = ts
    # Retry count: consecutive reviewer pres without a drafter pre between them.
    if (agent == "socratic-drafter") {
      turn_drafter_seen = 1
      reviewer_in_turn = 0
    }
    if (agent == "socratic-reviewer") {
      reviewer_in_turn += 1
      if (reviewer_in_turn > 1) retries_total += 1
    }
  }
  else if (phase == "post" && tool == "Agent") {
    if (agent in pre) {
      d = ts - pre[agent]
      if (agent == "socratic-drafter") drafter[++ndrafter] = d
      else if (agent == "socratic-reviewer") reviewer[++nreviewer] = d
      delete pre[agent]
    }
  }
  else if (phase == "submit") {
    last_submit_ts = ts
    submits_total += 1
    awaiting_first_pre = 1
  }

  # Parent-side TTFT: gap between submit and the next pre Agent.
  if (phase == "pre" && tool == "Agent" && awaiting_first_pre == 1) {
    ttft[++nttft] = ts - last_submit_ts
    awaiting_first_pre = 0
  }

  # Inter-stage gap: drafter post -> reviewer pre.
  if (phase == "post" && agent == "socratic-drafter") {
    last_drafter_post = ts
  }
  if (phase == "pre" && agent == "socratic-reviewer" && last_drafter_post > 0) {
    gap = ts - last_drafter_post
    # Drop gaps > 60s — those indicate idle time between unrelated turns,
    # not actual parent processing between drafter-post and reviewer-pre.
    if (gap < 60) interstage[++ninter] = gap
    last_drafter_post = 0
  }

  # Cache-token capture (extra fields if hook captured them).
  for (i = 5; i <= NF; i++) {
    if ($i ~ /^cache_read=/) {
      v = substr($i, 12) + 0
      cache_read_total += v; cache_read_n += 1
    }
    if ($i ~ /^cache_write=/) {
      v = substr($i, 13) + 0
      cache_write_total += v; cache_write_n += 1
    }
  }

  # Stop-hook verdicts (pattern: "stop-verdict PASS|FAIL-N len=..." or older "skip clean"/"review ..." markers).
  if (phase == "stop-verdict") { stop_verdict_total += 1; if (tool ~ /^FAIL/) stop_fail += 1 }
  if (phase == "skip" || phase == "review") legacy_verdicts += 1
}

END {
  print "=== Socratic pipeline latency report ==="
  print ""
  print "Source log:", "'"$LOG"'"
  print ""
  print "Stage durations:"
  summary("drafter (Agent)",  drafter,  ndrafter)
  summary("reviewer (Agent)", reviewer, nreviewer)
  summary("inter-stage gap",  interstage, ninter)
  summary("parent TTFT",      ttft, nttft)
  print ""
  printf "Turns observed (submit lines): %d\n", submits_total
  printf "Reviewer retries observed:    %d (extra reviewer spawns beyond first-per-turn)\n", retries_total
  if (submits_total > 0) {
    printf "Retry rate per turn:          %.1f%%\n", 100.0 * retries_total / submits_total
  }
  print ""
  if (cache_read_n > 0 || cache_write_n > 0) {
    print "Cache tokens (post-tool):"
    crm = 0; if (cache_read_n > 0) crm = cache_read_total / cache_read_n
    cwm = 0; if (cache_write_n > 0) cwm = cache_write_total / cache_write_n
    printf "  cache_read_input_tokens  total=%d  samples=%d  mean=%.0f\n", cache_read_total, cache_read_n, crm
    printf "  cache_creation_input_tokens total=%d  samples=%d  mean=%.0f\n", cache_write_total, cache_write_n, cwm
  } else {
    print "Cache tokens: (not surfaced to hook input — see Phase 0 plan note)"
  }
  print ""
  printf "Stop-hook verdicts: total=%d  fails=%d  legacy=%d\n", stop_verdict_total, stop_fail, legacy_verdicts
}
' "$LOG"
