#!/usr/bin/env bash
# Hook: Latency logger
# Events: PreToolUse, PostToolUse (matcher: Agent)
# Purpose: Record START/END timestamps for Agent tool calls so we can measure
# per-stage pipeline latency (drafter / reviewer / stop-hook-agent).
#
# Invocation:
#   latency-log.sh pre    # wire from PreToolUse
#   latency-log.sh post   # wire from PostToolUse
#
# Output: appends one line per event to .claude/latency.log
#   <epoch_seconds.nanos> <pre|post> <tool_name> <subagent_type>

PHASE="${1:-?}"
LOG="${CLAUDE_PROJECT_DIR}/.claude/latency.log"
TS=$(date +%s.%N)

INPUT=$(cat)

# Best-effort field extraction without jq dependency.
TOOL=$(printf '%s' "$INPUT" | grep -oE '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"([^"]+)"$/\1/')
SUBAGENT=$(printf '%s' "$INPUT" | grep -oE '"subagent_type"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"([^"]+)"$/\1/')

printf '%s %s %s %s\n' "$TS" "$PHASE" "${TOOL:--}" "${SUBAGENT:--}" >> "$LOG"

exit 0