#!/usr/bin/env bash
# Hook: Rubric drift check
# Purpose: Verify that the Socratic anti-pattern rubric stays in sync across
# the canonical source (.claude/rules/stop-criteria.md) and its single
# inlined copy in socratic-reviewer.md.
#
# Checks the EXACT heading string (e.g., "**Confirm + elaborate** —"), not
# just the anti-pattern name, so renames in one location are caught.
#
# Invocation: run manually or wire to SessionStart / pre-commit.
# Exit 0 = in sync, exit 1 = drift detected.

set -u

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"

CANONICAL="$PROJECT_DIR/.claude/rules/stop-criteria.md"
REVIEWER="$PROJECT_DIR/.claude/agents/socratic-reviewer.md"

# Exact heading strings that MUST appear verbatim in every mirror location.
# If a heading is renamed in one location, this check fails.
ANTI_PATTERN_HEADINGS=(
  "**Confirm + elaborate** —"
  "**Summary handoff** —"
  "**Tool/command specification** —"
  "**Design decision** —"
  "**Generic response** —"
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
  for heading in "${ANTI_PATTERN_HEADINGS[@]}"; do
    if ! grep -qF "$heading" "$file"; then
      echo "[drift-check] DRIFT in $label: missing heading \"$heading\""
      FAIL=1
    fi
  done
}

check_file "$CANONICAL" "stop-criteria.md (canonical)"
check_file "$REVIEWER"  "socratic-reviewer.md"

if [ "$FAIL" -eq 0 ]; then
  echo "[drift-check] OK — all 5 anti-pattern headings present in all 2 locations."
  exit 0
else
  echo "[drift-check] FAIL — edit both files (or delete the inlined copy and restore the Read-on-demand pattern)."
  exit 1
fi