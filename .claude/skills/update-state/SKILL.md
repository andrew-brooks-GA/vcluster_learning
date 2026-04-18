---
name: update-state
description: Updates both LEARNER_STATE.md and DESIGN.md in the correct sequence (state first, design second). Use at every milestone completion, or whenever both scaffolding observations and design decisions need to be persisted from the current conversation. This is the canonical post-milestone composite updater — prefer it over calling update-learner-state or update-design individually when both files need updating.
disable-model-invocation: false
user-invocable: true
allowed-tools: Read, Edit, Write, Glob
argument-hint: [milestone-name] [project-folder]
---

Update both tracking files from this conversation in the correct sequence.

## Steps

0. **Target file**: The target file is `LEARNER_STATE.md`. If `$ARGUMENTS` is provided, split on spaces: first token → milestone name, second token → project folder.

1. Run the `update-learner-state` skill first (pass `$ARGUMENTS[0]` as the milestone name if provided).
   - LEARNER_STATE.md is updated first because scaffolding observations inform what to record in DESIGN.md.
   - The `update-learner-state` skill handles taxonomy guard and self-assessment gate internally.

2. Check for skip-if-no-changes: if no concept proficiency changed and no self-assessment was given, note this and still proceed to step 3.

3. Run the `update-design` skill second (pass `$ARGUMENTS[1]` as the project folder if provided).
   - If no new design decisions were made in the conversation, say so and skip the write.

4. Show a combined summary: what changed in the state file and what changed in DESIGN.md (or "no changes" for either).

## Rules

- Always run state file update before DESIGN.md — the sequence is not optional.
- Skip-if-no-changes applies independently to each file.
- Do not modify files that have no changes to record.
- The target state file is always `LEARNER_STATE.md`.