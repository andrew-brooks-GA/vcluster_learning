#!/usr/bin/env bash
# Hook: Inject structured learner context before context compaction
# Event: PreCompact
# Purpose: Ensure current milestone, GAL, SRL phase, and recent concept encounters
#          survive compaction. Outputs a compact structured summary.

STATE_FILE="${CLAUDE_PROJECT_DIR}/LEARNER_STATE.md"

if [ ! -f "$STATE_FILE" ]; then
  echo "[LP-INFO:precompact] State file not found: $STATE_FILE"
  exit 0
fi

# Structured fields from SCAFFOLDING CALIBRATION block
MILESTONE=$(grep -m1 "^Milestone:" "$STATE_FILE" 2>/dev/null | sed 's/Milestone: //')
PHASE=$(grep -m1 "^Phase:" "$STATE_FILE" 2>/dev/null | sed 's/Phase: //')
SCAFFOLDING=$(grep -m1 "^Scaffolding Range:" "$STATE_FILE" 2>/dev/null | sed 's/Scaffolding Range: //')
GAL=$(awk '/^## Global Autonomy Level/{found=1; next} found && /^Level:/{print; exit}' "$STATE_FILE" 2>/dev/null | sed 's/Level: //')

# Position (fallback)
POSITION=$(grep -m1 "^## Current Position" -A1 "$STATE_FILE" 2>/dev/null | tail -1 | sed 's/^[[:space:]]*//')

# Last 5 concept encounters
RECENT_CONCEPTS=$(awk '/^## Concept Proficiency/{found=1; next} found && /^\|/{print}' "$STATE_FILE" 2>/dev/null | grep -v "^| Concept\|^|---" | head -5)

# Last self-assessment
LAST_SCORE=$(awk '/^## Self-Assessments/{found=1; next} found && /^\| [A-Z]/{print; exit}' "$STATE_FILE" 2>/dev/null)

echo "=== LEARNER STATE (PreCompact) ==="
echo "Position: ${MILESTONE:-${POSITION:-unknown}}"
[ -n "$PHASE" ] && echo "Phase: $PHASE"
[ -n "$SCAFFOLDING" ] && echo "Scaffolding: $SCAFFOLDING"
echo "Global Autonomy Level: ${GAL:-1}"
echo ""

if [ -n "$RECENT_CONCEPTS" ]; then
  echo "Recent concepts (last 5):"
  echo "$RECENT_CONCEPTS"
  echo ""
fi

[ -n "$LAST_SCORE" ] && echo "Last self-assessment: $LAST_SCORE" && echo ""

echo "=== ACTIVE DESIGN DOCS ==="
find "${CLAUDE_PROJECT_DIR}" -name 'DESIGN.md' \
  -exec echo '--- {} ---' \; -exec cat {} \; 2>/dev/null

exit 0
