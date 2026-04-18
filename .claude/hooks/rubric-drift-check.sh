#!/usr/bin/env bash
# Hook: Rubric drift check
# Purpose: Verify that the Socratic anti-pattern rubric stays in sync across
# the canonical source (.claude/rules/stop-criteria.md) and its inlined copies
# in socratic-reviewer.md, socratic-drafter.md, and settings.json.
#
# Invocation: run manually or wire to SessionStart / pre-commit.
# Exit 0 = in sync, exit 1 = drift detected.

set -u

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"

CANONICAL="$PROJECT_DIR/.claude/rules/stop-criteria.md"
REVIEWER="$PROJECT_DIR/.claude/agents/socratic-reviewer.md"
DRAFTER="$PROJECT_DIR/.claude/agents/socratic-drafter.md"
SETTINGS="$PROJECT_DIR/.claude/settings.json"

# The canonical anti-pattern names. If one goes missing from any inlined copy,
# someone edited one place and forgot the others.
ANTI_PATTERNS=(
  "Confirm + elaborate"
  "Summary handoff"
  "Tool/command specification"
  "Design decision"
  "Generic response"
)

FAIL=0

check_file() {
  local file="$1"
  local label="$2"
  if [ ! -f "$file" ]; then
    echo "[drift-check] MISSING FILE: $label ($file)"
    FAIL=1
    return
  fi
  for pattern in "${ANTI_PATTERNS[@]}"; do
    if ! grep -qF "$pattern" "$file"; then
      echo "[drift-check] DRIFT in $label: missing anti-pattern \"$pattern\""
      FAIL=1
    fi
  done
}

check_file "$CANONICAL" "stop-criteria.md (canonical)"
check_file "$REVIEWER"  "socratic-reviewer.md"
check_file "$DRAFTER"   "socratic-drafter.md"
check_file "$SETTINGS"  "settings.json (Stop hook prompt)"

if [ "$FAIL" -eq 0 ]; then
  echo "[drift-check] OK — all 5 anti-patterns present in all 4 locations."
  exit 0
else
  echo "[drift-check] FAIL — edit all four files (or delete the inlined copy and restore the Read-on-demand pattern)."
  exit 1
fi