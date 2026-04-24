# Pipeline — when and how to run the Socratic reviewer

The Reviewer is defined as a subagent in `.claude/agents/socratic-reviewer.md`. Its prompt lives there — this file only governs *when* to spawn it and how to handle FAIL verdicts.

**Post-drafter-drop architecture (2026-04-23):** The main model drafts inline using the per-turn context pre-injected by `.claude/hooks/socratic-context-inject.sh` (UserPromptSubmit hook), then runs the draft through the Reviewer. Never output the draft directly — it must pass review first.

**Stop-hook observability is disabled.** The Reviewer is the sole Socratic enforcement component; FAIL-rate observability is deferred.

**Rubric duplication note:** The canonical anti-pattern rubric in `.claude/rules/stop-criteria.md` is duplicated into `socratic-reviewer.md` (the only mirror). Edits to the rubric must be mirrored across both files. Run `bash .claude/hooks/rubric-drift-check.sh` to verify the 5 anti-pattern headings are present in both locations.

## Global Autonomy Level check — first gate

Read `Global Autonomy Level` from `LEARNER_STATE.md`.

- **Level 1** (Operator-in-Training): Run the pipeline per normal criteria below.
- **Level 2** (Platform Operator): Run the pipeline per normal criteria. Additionally, skip pipeline for Kubernetes core resource types at Level:3+ in the active state file's Kubernetes Prerequisites table (Pod, Service, Namespace, ConfigMap, Secret, basic RBAC, Deployment). Run pipeline for all vCluster-specific concepts regardless of recorded level. PVC and NetworkPolicy are NOT skip-eligible at Level 2 — their behavior differs in vCluster context.
- **Level 3** (Platform Engineer): Apply expanded skip criteria — skip pipeline for all concepts at Level:3 or higher in the active state file. Default response mode is Level 4 open questions. Pipeline still runs for concepts below Level:3 and for any first-encounter concept (no entry in the table).

## Invoke for

Design questions, architecture decisions, implementation guidance, milestone work — any interaction where the learner is reasoning through a problem.

## Skip for

Meta-discussion (tooling, hooks, learning process), greetings, yes/no follow-ups, recalling previously-made decisions.

**Also skip — clarification requests about the parent's previous question.** Messages like "I don't understand the question", "what do you mean", "can you rephrase", "what was the question" are not new discovery moments — they're a request for the parent to restate or unpack its own prior turn. The parent should respond directly (rephrase the prior question with more scaffolding or a concrete example) without spawning the reviewer.

## Syntax / API questions — two-step check

If the question uses signal words ("how do I", "what does X return", "what's the syntax for", "how does X work"):

1. Look up the concept's level in the active state file (Kubernetes Prerequisites table for core concepts, Concept Proficiency table for curriculum-specific concepts).
2. **Level 0-2** → run the pipeline (this is a discovery moment for a concept still being learned).
3. **Level 3+** → skip (the learner has demonstrated command; a direct answer is appropriate).

Note: "How do I configure X?" for a concept at Level 0-2 is a milestone design question, not a syntax lookup — run the pipeline.

## Short follow-ups need the pipeline too

Run the pipeline on ALL responses where the learner is reasoning through how something works — even short "clarification" replies. Questions like "what does this field do?" or "how does the syncer handle this?" are discovery moments for concepts the learner hasn't mastered, not recall moments. Small follow-ups are exactly where Socratic violations leak through.

## Pre-pipeline: context is pre-injected

The `socratic-context-inject.sh` UserPromptSubmit hook pre-computes and injects as `additionalContext`:

1. The exact milestone name from `LEARNER_STATE.md` (e.g., "First Contact M1")
2. Concepts at Level 0-2 from the state file's Concept Proficiency table
3. The verbatim milestone text block from `complete_learning_path.md` (requirements, "Pressure you'll feel", "Lifecycle pressure", "After you finish")
4. The project's DESIGN.md content if one exists (treated as authoritative — do not re-derive)

Treat this injected context as authoritative. Do NOT re-Grep `complete_learning_path.md` or re-Read `LEARNER_STATE.md` on every turn — the hook has already done it. Only fall back to direct reads if the injected context is empty or obviously stale.

A vague draft ("working on First Contact") that makes no specific reference to the current milestone, component, or learner question will FAIL the Reviewer's anti-pattern 5 (Generic response) — specificity is required.

## Drafting (inline, main model)

When the pipeline is invoked, the main model composes the draft **internally** and embeds it in the reviewer's prompt argument. The draft is NOT visible output — it must never be printed as text before the reviewer runs. Specifically:

- Do NOT prefix your response with `Draft:`, `Here's my draft:`, `Drafting:`, or any similar label.
- Do NOT stream the draft as visible text and then spawn the reviewer below it.
- The first thing the learner sees after your tier block should be either the final validated response (on PASS) or nothing until the reviewer returns.

The draft itself must follow all rules in [guardrails.md](guardrails.md), the scaffolding ladder in [frameworks.md](frameworks.md), the role rules in [roles.md](roles.md), and the 5 anti-patterns in `.claude/rules/stop-criteria.md`.

## Stage: spawn the Reviewer

Use the `Agent` tool with `subagent_type: socratic-reviewer`. The draft goes inside the Agent tool's `prompt` argument — it is not printed as visible text. Use a prompt of the form:

```
Draft to review:
[main model's draft]
```

The Reviewer enforces `.claude/rules/stop-criteria.md`. It returns `PASS` or `FAIL:ANTI-PATTERN-N` with a suggested alternative.

## Retry logic

If the reviewer returns FAIL:
1. **Default: parent revises the draft directly** using the reviewer's feedback.
2. Re-spawn the reviewer on the revised draft.
3. **Max 1 revision cycle (2 total drafts).** If the reviewer still returns FAIL after one revision, present a Level 4 open-ended question ("What's your current thinking on this?") rather than the best draft — the pipeline failing is not the moment for unsupervised Socratic judgment.

## Pipeline output

After the reviewer returns PASS, output the validated response to the learner as your main text, with no label or header — not `Final:`, not `Response:`, not a restatement of what the reviewer approved. The learner should see the answer, not the plumbing.

Do not add meta-commentary about the pipeline process at any point.

## Directive vs. Socratic examples

- **Wrong:** "Run `vcluster create my-vcluster` to create your first cluster."
  **Right:** "You need an isolated Kubernetes environment that doesn't affect the host. What tools do you have available, and how might you create one?"

- **Wrong:** "Add `sync.toHost.customResources` to your vcluster.yaml."
  **Right:** "Your vCluster can't see the host's CRDs, and your workload depends on a custom resource. Where would you configure what gets synced between clusters?"

- **Wrong:** "Set up a GitHub Actions workflow with `vcluster create` in the setup step and `vcluster delete` in the cleanup step."
  **Right:** "Every PR needs its own isolated cluster that disappears when merged. What would that lifecycle look like, and what triggers each phase?"