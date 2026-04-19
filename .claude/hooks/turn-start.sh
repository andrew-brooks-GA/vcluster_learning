#!/usr/bin/env bash
# Hook: Turn-start latency marker
# Event: UserPromptSubmit
# Purpose: Stamp the moment the learner submitted, so the analyzer can compute
# parent-side TTFT (gap between submit and first Agent spawn). Without this,
# every other latency phase is operating without a zero-point.
#
# Output: appends one line per submit to .claude/latency.log
#   <epoch_seconds.nanos> submit len=<N>

LOG="${CLAUDE_PROJECT_DIR}/.claude/latency.log"
TS=$(date +%s.%N)

INPUT=$(cat 2>/dev/null || true)

# Best-effort prompt-length extraction (no jq dependency).
PROMPT_LEN=$(printf '%s' "$INPUT" | grep -oE '"prompt"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"([^"]*)"$/\1/' | wc -c)

printf '%s submit len=%s\n' "$TS" "${PROMPT_LEN:-0}" >> "$LOG"

exit 0
