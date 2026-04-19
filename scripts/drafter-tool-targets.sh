#!/usr/bin/env bash
# scripts/drafter-tool-targets.sh
# Phase 5 helper — extract Read/Grep/Glob target paths captured during
# socratic-drafter execution windows from .claude/latency.log.
#
# Each `tool-target` line whose timestamp falls between a `pre Agent
# socratic-drafter` and the matching `post Agent socratic-drafter` is
# attributed to the drafter. All others are attributed to "other"
# (parent or other subagent context).
#
# Usage:
#   bash scripts/drafter-tool-targets.sh                   # full log
#   bash scripts/drafter-tool-targets.sh path/to/log       # specific log

set -u
LOG="${1:-${CLAUDE_PROJECT_DIR:-.}/.claude/latency.log}"

if [ ! -f "$LOG" ]; then
  echo "ERROR: log file not found: $LOG" >&2
  exit 1
fi

awk '
{
  ts = $1 + 0
  phase = $2
  tool = $3
  agent = $4

  if (phase == "pre" && tool == "Agent" && agent == "socratic-drafter") {
    in_drafter = 1
    drafter_window_start = ts
    drafter_windows += 1
  }
  else if (phase == "post" && tool == "Agent" && agent == "socratic-drafter") {
    in_drafter = 0
  }
  else if (phase == "tool-target") {
    target_tool = $3
    # rebuild the rest of the line as the target string
    target = ""
    for (i = 4; i <= NF; i++) target = target (i==4 ? "" : " ") $i

    if (in_drafter) {
      key = target_tool " :: " target
      drafter_targets[key] += 1
      drafter_count += 1
    } else {
      key = target_tool " :: " target
      other_targets[key] += 1
      other_count += 1
    }
  }
}

END {
  print "=== Drafter tool-target audit ==="
  print ""
  printf "Source log:       %s\n", "'"$LOG"'"
  printf "Drafter windows:  %d\n", drafter_windows
  printf "Drafter targets:  %d\n", drafter_count
  printf "Other targets:    %d\n", other_count
  print ""
  print "--- Targets observed inside drafter execution windows ---"
  if (drafter_count == 0) {
    print "  (none yet — run more curriculum turns to accumulate samples)"
  } else {
    for (k in drafter_targets) {
      printf "  %4d  %s\n", drafter_targets[k], k
    }
  }
  print ""
  print "--- Targets observed OUTSIDE drafter windows (parent/reviewer/other) ---"
  if (other_count == 0) {
    print "  (none)"
  } else {
    for (k in other_targets) {
      printf "  %4d  %s\n", other_targets[k], k
    }
  }
  print ""
  print "Decision rule (Phase 5 plan):"
  print "  If drafter targets are confined to .claude/skills/socratic-mentoring/* and LEARNER_STATE.md"
  print "  across ≥3 distinct sessions, drop Grep+Glob from drafter tools (Read-only)."
}
' "$LOG"
