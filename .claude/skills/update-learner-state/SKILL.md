---
name: update-learner-state
description: Update LEARNER_STATE.md with concept proficiency, scaffolding observations, and self-assessment data from this conversation
disable-model-invocation: false
user-invocable: true
allowed-tools: Read, Edit, Write
argument-hint: [milestone-name]
---

Update the learner state tracking file with observations from this conversation.

## Steps

0. **Target file**: The target file for all reads and writes is `LEARNER_STATE.md`.

1. **Taxonomy guard**: Read the target state file. Before writing any concept proficiency entry, confirm the concept belongs to the curriculum's taxonomy:
   - vCluster taxonomy: syncer, backing store, network isolation, name rewriting, custom resource syncing, vcluster.yaml config, control plane variants, DNS, GitOps, multi-tenancy, RBAC, vCluster lifecycle, platform UI, etc.
   - Kubernetes Prerequisites: Pod, Service, Namespace, ConfigMap, Secret, RBAC, Deployment — write to the `## Kubernetes Prerequisites` table, not the Concept Proficiency table.

2. Determine the milestone context. If `$ARGUMENTS` is provided, use that as the milestone name. Otherwise, infer from conversation context.

3. Review the conversation for:
   - **Concept proficiency changes**: concepts the learner worked with, the scaffolding level they reached, and notable observations.
   - **Self-assessment data**: if the learner provided design/implementation/transfer confidence ratings.
   - **Current position**: update if it has changed.

3b. **Self-assessment gate**: If this update includes advancing the current milestone to completed status, verify the learner has provided self-assessment ratings (design / implementation / transfer confidence) for the milestone being completed. If ratings have NOT been provided in this conversation:
   - Ask: *"Before recording this milestone completion, rate your confidence on three dimensions (1–5 scale): **Design** (could you make the major design decisions again without help?), **Implementation** (could you reproduce this from scratch without notes?), **Transfer** (could you apply this pattern to a different but similar problem?)"*
   - Wait for their response before writing milestone completion.
   - Exception: If the Progress Tracker role already collected self-assessment ratings earlier in this session, proceed without re-asking.

4. Update the target state file:
   - Add or update rows in the Concept Proficiency table using `Level:N` notation and ISO dates (YYYY-MM-DD). Update in place; do not add duplicate rows.
   - Add a row to Self-Assessments if the learner completed a milestone self-assessment. Use N/5 format.
   - Update `## Current Position` if the milestone changed.
   - Update `## SCAFFOLDING CALIBRATION` block to reflect current milestone and scaffolding range.
   - Update `## Global Autonomy Level` if a project boundary was crossed (Level updates at project boundaries only).
   - Add notable scaffolding observations to Scaffolding Notes.

5. Show the user a brief summary of what was updated.

## Rules

- Only record observations supported by the conversation — do not infer proficiency levels not demonstrated.
- Scaffolding levels use the 0-4 scale: 0 = needed full explanation, 4 = needed only an open question. Write as `Level:N`.
- Use ISO dates (YYYY-MM-DD) in the `Last_Seen` column.
- Self-assessment entries are self-reported (1–5 scale). Never label them as examiner-evaluated.
- Keep entries concise — one line per concept, brief notes.
- Do not remove or overwrite existing entries. Update in place or append.
- If no meaningful state changes occurred, say so and do not modify the file.
- To update both LEARNER_STATE.md and DESIGN.md in sequence, use the /update-state composite skill instead.