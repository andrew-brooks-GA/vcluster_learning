#!/usr/bin/env bash
# Hook: Socratic context injector
# Event: UserPromptSubmit
# Purpose: Pre-compute per-turn curriculum context (current milestone name,
# Level 0-2 concepts, verbatim milestone block) and emit it as
# additionalContext so the main model drafts inline without parent-side
# Grep+Read. Replaces the Drafter-subagent's pre-pipeline context load.
#
# vcluster_learning curriculum uses these heading patterns:
#   Project:   ^# Project <N>: <name> `[tags]`
#   Milestone: ^## M<N>: <title> `[tags]`
#
# If the current milestone cannot be determined, emit empty stdout and exit 0
# — the main model proceeds without extra context.
#
# Output: JSON to stdout matching the UserPromptSubmit hookSpecificOutput
# schema documented at https://docs.claude.com/en/docs/claude-code/hooks.

set -u

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
STATE="$PROJECT_DIR/LEARNER_STATE.md"
CURRICULUM="$PROJECT_DIR/complete_learning_path.md"

# Silent exit if prereqs missing — main model proceeds without context.
[ -f "$STATE" ] || exit 0
[ -f "$CURRICULUM" ] || exit 0

# Extract current milestone: first "Milestone: <project name> M<N>" line,
# tolerating trailing "(in progress)" / "(not started)" / "(completed)".
MILESTONE_LINE=$(grep -m1 -E '^Milestone: .+ M[0-9]+' "$STATE" | head -1)
[ -n "$MILESTONE_LINE" ] || exit 0

# "Milestone: First Contact M1 (not started)" -> "First Contact M1"
MILESTONE=$(printf '%s' "$MILESTONE_LINE" | sed -E 's/^Milestone: (.+ M[0-9]+).*$/\1/')
PROJECT=$(printf '%s' "$MILESTONE" | sed -E 's/ M[0-9]+$//')
MNUM=$(printf '%s' "$MILESTONE" | sed -E 's/^.* M([0-9]+)$/\1/')

# Locate the project heading. vcluster uses "# Project N: <name>" as a top-level
# heading, with milestones "## MN: <title>" nested beneath it. Match the project
# name as a substring of a "# Project" line.
PROJECT_START=$(grep -nE "^# Project [0-9]+: " "$CURRICULUM" | grep -F "$PROJECT" | head -1 | cut -d: -f1)
[ -n "$PROJECT_START" ] || exit 0

# Locate "## M<N>:" heading at or after PROJECT_START (inside this project).
MS_START=$(awk -v start="$PROJECT_START" -v mnum="$MNUM" '
  NR >= start && $0 ~ ("^## M" mnum ":") { print NR; exit }
' "$CURRICULUM")
[ -n "$MS_START" ] || exit 0

# End of milestone block: the next "## " or "# " heading, whichever comes first.
MS_END=$(awk -v start="$MS_START" '
  NR > start && /^#[# ]/ { print NR - 1; exit }
' "$CURRICULUM")
[ -n "$MS_END" ] || MS_END=$(wc -l < "$CURRICULUM")

MILESTONE_BLOCK=$(sed -n "${MS_START},${MS_END}p" "$CURRICULUM")

# Level 0-2 concepts from the Concept Proficiency table.
CONCEPTS=$(awk '
  /^## Concept Proficiency/ { in_tbl = 1; next }
  in_tbl && /^## / { exit }
  in_tbl && /Level:[012][^0-9]/ {
    split($0, cells, "|")
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", cells[2])
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", cells[4])
    if (cells[2] != "" && cells[2] != "Concept") print "- " cells[2] " (" cells[4] ")"
  }
' "$STATE")

# Project DESIGN.md — try a few directory name conventions since vcluster's
# project directory structure is learner-chosen. If none found, DESIGN_CONTENT
# stays empty and the block is omitted from context.
PROJ_COMPACT=$(printf '%s' "$PROJECT" | tr -d ' ')
PROJ_KEBAB=$(printf '%s' "$PROJECT" | tr '[:upper:] ' '[:lower:]-')
DESIGN_CONTENT=""
for candidate in \
    "$PROJECT_DIR/$PROJ_COMPACT/DESIGN.md" \
    "$PROJECT_DIR/$PROJ_KEBAB/DESIGN.md" \
    "$PROJECT_DIR/project-$MNUM/DESIGN.md" \
    "$PROJECT_DIR/p$MNUM/DESIGN.md"; do
    if [ -f "$candidate" ]; then
        DESIGN_CONTENT=$(cat "$candidate")
        break
    fi
done

# Assemble context. Omit the DESIGN block entirely when empty so the learner
# sees a clean context rather than an empty-section placeholder.
if [ -n "$DESIGN_CONTENT" ]; then
    CONTEXT=$(cat <<EOF
Current milestone: $MILESTONE

Level 0-2 concepts (relevant to this learner right now):
$CONCEPTS

Milestone text (verbatim from complete_learning_path.md):
$MILESTONE_BLOCK

Project design decisions already made (DESIGN.md — treat as authoritative; do not re-derive):
$DESIGN_CONTENT
EOF
)
else
    CONTEXT=$(cat <<EOF
Current milestone: $MILESTONE

Level 0-2 concepts (relevant to this learner right now):
$CONCEPTS

Milestone text (verbatim from complete_learning_path.md):
$MILESTONE_BLOCK
EOF
)
fi

# JSON-escape: backslash, double-quote, tab. Emit a literal \n between input
# lines; ORS="" suppresses awk's default trailing newline.
ESCAPED=$(printf '%s' "$CONTEXT" | awk '
  BEGIN { ORS = "" }
  NR > 1 { printf "\\n" }
  {
    gsub(/\\/, "\\\\")
    gsub(/"/, "\\\"")
    gsub(/\t/, "\\t")
    print
  }
' )

printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"%s"}}\n' "$ESCAPED"
exit 0
