---
name: update-design
description: Appends new infrastructure design decisions from the current conversation to the active project's DESIGN.md — new components, changed responsibilities, architectural choices, scope decisions, rejected alternatives. Use when a milestone produced design decisions not yet captured (typically after a Design Reviewer role has approved a configuration), or when the learner explicitly asks to document what they chose and why. Skips writing if no new decisions were explicitly agreed upon.
disable-model-invocation: false
user-invocable: true
allowed-tools: Read, Edit, Write, Glob
argument-hint: [project-folder]
---

Update the design document for the current project with any new design decisions made in this conversation.

## Steps

1. Determine the target project. If `$ARGUMENTS` is provided, use that as the project folder name (e.g., `ParkingGarage`). Otherwise, infer from conversation context.
2. Find the DESIGN.md file using `Glob` pattern `**/DESIGN.md` within the project folder.
3. Read the current DESIGN.md to understand what's already documented.
4. Review the conversation for design decisions not yet captured in the document — new classes, changed responsibilities, architectural choices, scope decisions, rejected alternatives.
5. Update the DESIGN.md by appending or editing the relevant sections. Preserve existing content. Add new decisions under the appropriate milestone heading.
6. Show the user a brief summary of what was added.

## Rules

- Only add decisions that were explicitly agreed upon in conversation — do not infer or extrapolate.
- If no new decisions were made, say so and don't modify the file.
- Keep the document concise — bullet points, not paragraphs.
- If DESIGN.md doesn't exist yet, create it with a heading matching the project name.
- Do not modify files that have no changes to record.
- To update both DESIGN.md and LEARNER_STATE.md in sequence, use the /update-state composite skill instead.