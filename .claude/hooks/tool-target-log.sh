#!/usr/bin/env bash
# Hook: Tool-target logger (Phase 5 instrumentation — TEMPORARY)
# Events: PreToolUse (matcher: Read|Grep|Glob)
# Purpose: Capture file_path / pattern targets for Read, Grep, Glob calls so
# we can post-hoc determine which paths the socratic-drafter subagent reads
# during its execution window. Cross-reference timestamps against
# drafter pre/post pairs in .claude/latency.log to identify drafter-originated
# calls.
#
# REMOVAL: Once the drafter's read set is confirmed closed across ≥3 sessions
# (Phase 5 plan), remove this hook block from .claude/settings.json and
# delete this script.
#
# Output: appends one line per Read/Grep/Glob call to .claude/latency.log
#   <epoch_seconds.nanos> tool-target <tool_name> <target>

LOG="${CLAUDE_PROJECT_DIR}/.claude/latency.log"
TS=$(date +%s.%N)

INPUT=$(cat 2>/dev/null || true)

TOOL=$(printf '%s' "$INPUT" | grep -oE '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"([^"]+)"$/\1/')

# Target field varies by tool: Read uses "file_path", Grep/Glob use "pattern" (and Grep also "path").
TARGET=""
case "$TOOL" in
  Read)
    FP=$(printf '%s' "$INPUT" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"([^"]*)"$/\1/')
    OFF=$(printf '%s' "$INPUT" | grep -oE '"offset"[[:space:]]*:[[:space:]]*[0-9]+' | head -1 | grep -oE '[0-9]+$')
    LIM=$(printf '%s' "$INPUT" | grep -oE '"limit"[[:space:]]*:[[:space:]]*[0-9]+' | head -1 | grep -oE '[0-9]+$')
    TARGET="${FP:--} offset=${OFF:--} limit=${LIM:--}"
    ;;
  Grep)
    PAT=$(printf '%s' "$INPUT" | grep -oE '"pattern"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"([^"]*)"$/\1/')
    GPATH=$(printf '%s' "$INPUT" | grep -oE '"path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"([^"]*)"$/\1/')
    TARGET="pattern=${PAT:--} path=${GPATH:--}"
    ;;
  Glob)
    PAT=$(printf '%s' "$INPUT" | grep -oE '"pattern"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"([^"]*)"$/\1/')
    TARGET="pattern=${PAT:--}"
    ;;
  *)
    TARGET="-"
    ;;
esac

# Replace whitespace in target so log stays one-line-per-event and awk-friendly.
TARGET=$(printf '%s' "$TARGET" | tr '\n\t' '  ')

printf '%s tool-target %s %s\n' "$TS" "${TOOL:--}" "${TARGET:--}" >> "$LOG"

exit 0
