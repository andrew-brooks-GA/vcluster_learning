#!/usr/bin/env bash
# Hook: Session orientation
# Event: SessionStart
# Purpose: Emit relevant learner state summary from LEARNER_STATE.md.
# Exit 0 = allow (this hook never blocks).

STATE_FILE="${CLAUDE_PROJECT_DIR}/LEARNER_STATE.md"

if [ ! -f "$STATE_FILE" ]; then
  echo "[ORIENT:session] State file not found: $STATE_FILE"
  exit 0
fi

# Extract structured fields (SCAFFOLDING CALIBRATION section)
MILESTONE=$(grep -m1 "^Milestone:" "$STATE_FILE" 2>/dev/null | sed 's/Milestone: //')
PHASE=$(grep -m1 "^Phase:" "$STATE_FILE" 2>/dev/null | sed 's/Phase: //')
SCAFFOLDING=$(grep -m1 "^Scaffolding Range:" "$STATE_FILE" 2>/dev/null | sed 's/Scaffolding Range: //')
GAL=$(awk '/^## Global Autonomy Level/{found=1; next} found && /^Level:/{print; exit}' "$STATE_FILE" 2>/dev/null | sed 's/Level: //')

# Current position (fallback if structured fields absent)
POSITION=$(grep -m1 "^## Current Position" -A1 "$STATE_FILE" 2>/dev/null | tail -1 | sed 's/^[[:space:]]*//')

# Last 5 concept encounters
RECENT_CONCEPTS=$(awk '/^## Concept Proficiency/{found=1; next} found && /^\|/{print}' "$STATE_FILE" 2>/dev/null | grep -v "^| Concept\|^|---" | head -5)

echo "[ORIENT:session] vCluster curriculum — $(date +%Y-%m-%d)"
echo "- Current position: ${MILESTONE:-${POSITION:-unknown}}"
[ -n "$PHASE" ] && echo "- Phase: $PHASE"
[ -n "$SCAFFOLDING" ] && echo "- Scaffolding Range: $SCAFFOLDING"
echo "- Global Autonomy Level: ${GAL:-1}"

if [ -n "$RECENT_CONCEPTS" ]; then
  echo "- Recent concepts (last 5):"
  echo "$RECENT_CONCEPTS" | while IFS= read -r line; do
    echo "  $line"
  done
fi

exit 0
