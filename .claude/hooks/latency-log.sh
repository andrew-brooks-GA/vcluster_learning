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

# Cache-token capture (post phase only — input JSON may include usage block from Anthropic).
# If Claude Code does not surface these to PostToolUse, fields stay empty and we skip them.
CACHE_READ=""
CACHE_WRITE=""
if [ "$PHASE" = "post" ]; then
  CACHE_READ=$(printf '%s' "$INPUT" | grep -oE '"cache_read_input_tokens"[[:space:]]*:[[:space:]]*[0-9]+' | head -1 | grep -oE '[0-9]+$')
  CACHE_WRITE=$(printf '%s' "$INPUT" | grep -oE '"cache_creation_input_tokens"[[:space:]]*:[[:space:]]*[0-9]+' | head -1 | grep -oE '[0-9]+$')
fi

if [ -n "$CACHE_READ" ] || [ -n "$CACHE_WRITE" ]; then
  printf '%s %s %s %s cache_read=%s cache_write=%s\n' "$TS" "$PHASE" "${TOOL:--}" "${SUBAGENT:--}" "${CACHE_READ:-0}" "${CACHE_WRITE:-0}" >> "$LOG"
else
  printf '%s %s %s %s\n' "$TS" "$PHASE" "${TOOL:--}" "${SUBAGENT:--}" >> "$LOG"
fi

exit 0