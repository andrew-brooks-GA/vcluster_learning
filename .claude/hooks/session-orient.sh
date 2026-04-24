#!/usr/bin/env bash
# Hook: Session orientation
# Event: SessionStart
# Purpose: Emit a learner-facing reminder of how to work with the Socratic
# mentor, plus the structured state summary from LEARNER_STATE.md consumed by
# the mentor. Reminder fires once per calendar day (marker at
# .claude/.session-marker) so it anchors each working day without repeating
# across rapid session restarts.
# Exit 0 = allow (this hook never blocks).

STATE_FILE="${CLAUDE_PROJECT_DIR}/LEARNER_STATE.md"
MARKER="${CLAUDE_PROJECT_DIR}/.claude/.session-marker"

# Learner-facing reminder — once per calendar day.
if [ ! -f "$MARKER" ] || [ "$(cat "$MARKER" 2>/dev/null)" != "$(date +%Y%m%d)" ]; then
  echo "$(date +%Y%m%d)" > "$MARKER" 2>/dev/null || true
  cat <<'BANNER'
[MENTOR-HOWTO] Socratic mentoring is active.
  - The mentor asks guiding questions rather than handing over CLI commands or vcluster.yaml keys.
  - Say "just tell me" at any time to get a direct answer.
  - When stuck, say what you tried and where it broke — specifics get better hints.
  - Full methodology: see LEARNER_GUIDE.md (5-minute read, required for first-time learners).

BANNER
fi

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
