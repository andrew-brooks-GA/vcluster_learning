# Pipeline — when and how to run the Socratic drafter→reviewer sequence

The Drafter and Reviewer are defined as subagents in `.claude/agents/socratic-drafter.md` and `.claude/agents/socratic-reviewer.md`. Their prompts live there — this file only governs when to spawn them.

**Rubric duplication note:** For latency reasons (eliminating per-turn Read round-trips), the canonical anti-pattern rubric in `.claude/rules/stop-criteria.md` is duplicated into three places: `socratic-reviewer.md`, `socratic-drafter.md`, and the Stop hook `prompt` in `.claude/settings.json`. Edits to the rubric must be mirrored across all four files. Run `bash .claude/hooks/rubric-drift-check.sh` to verify the 5 anti-pattern names are present in every location.

## Global Autonomy Level check — first gate

Read `Global Autonomy Level` from `LEARNER_STATE.md`.

- **Level 1** (Operator-in-Training): Run the pipeline per normal criteria below.
- **Level 2** (Platform Operator): Run the pipeline per normal criteria. Additionally, skip pipeline for Kubernetes core resource types at Level:3+ in the active state file's Kubernetes Prerequisites table (Pod, Service, Namespace, ConfigMap, Secret, basic RBAC, Deployment). Run pipeline for all vCluster-specific concepts regardless of recorded level. PVC and NetworkPolicy are NOT skip-eligible at Level 2 — their behavior differs in vCluster context.
- **Level 3** (Platform Engineer): Apply expanded skip criteria — skip pipeline for all concepts at Level:3 or higher in the active state file. Default response mode is Level 4 open questions. Pipeline still runs for concepts below Level:3 and for any first-encounter concept (no entry in the table).

## Invoke for

Design questions, architecture decisions, implementation guidance, milestone work — any interaction where the learner is reasoning through a problem.

## Skip for

Meta-discussion (tooling, hooks, learning process), greetings, yes/no follow-ups, recalling previously-made decisions.

## Syntax / API questions — two-step check

If the question uses signal words ("how do I", "what does X return", "what's the syntax for", "how does X work"):

1. Look up the concept's level in the active state file (Kubernetes Prerequisites table for core concepts, Concept Proficiency table for curriculum-specific concepts).
2. **Level 0-2** → run the pipeline (this is a discovery moment for a concept still being learned).
3. **Level 3+** → skip (the learner has demonstrated command; a direct answer is appropriate).

Note: "How do I configure X?" for a concept at Level 0-2 is a milestone design question, not a syntax lookup — run the pipeline.

## Short follow-ups need the pipeline too

Run the pipeline on ALL responses where the learner is reasoning through how something works — even short "clarification" replies. Questions like "what does this field do?" or "how does the syncer handle this?" are discovery moments for concepts the learner hasn't mastered, not recall moments. Small follow-ups are exactly where Socratic violations leak through.

## Pre-pipeline: load context (required)

Before spawning the Drafter, read `LEARNER_STATE.md` to identify the current state. The context block passed to the Drafter **must** include all three of:

1. The exact milestone name from the curriculum (e.g., "First Contact M1")
2. The specific requirement the learner is currently working on
3. Any concepts from the state file at Level 0-2 that are relevant to the learner's question

A vague context injection ("working on First Contact") produces generic responses that then pass all Reviewer checks — specificity here is what makes the anti-pattern checks meaningful.

## Stage 1: spawn the Drafter

Use the `Agent` tool with `subagent_type: socratic-drafter`. Pass a prompt of the form:

```
Current context: [exact milestone name] | [specific requirement being worked on] | [Level 0-2 concepts from active state file relevant to this question]

Learner's message: [their exact message]
```

The Drafter's system prompt lives in `.claude/agents/socratic-drafter.md` — do not re-specify the rules here.

## Stage 2: spawn the Reviewer

Pass the Drafter's output to the `socratic-reviewer` subagent:

```
Draft to review:
[drafter's output]
```

The Reviewer loads `.claude/rules/stop-criteria.md` for anti-pattern definitions. It returns `PASS` or `FAIL: [anti-pattern and suggested alternative]`.

## Retry logic

If the reviewer returns FAIL:
1. Revise the draft using the reviewer's feedback (the parent can revise directly or re-spawn the drafter with the feedback appended).
2. Re-spawn the reviewer on the revised draft.
3. Max 2 revision cycles (3 total drafts). After that, present a Level 4 open-ended question ("What's your current thinking on this?") rather than the best draft — the pipeline failing is not the moment for unsupervised Socratic judgment. The Stop hook serves as a final safety net.

## Pipeline output

Present the final output to the learner. Do not add meta-commentary about the pipeline process.

## Directive vs. Socratic examples

- **Wrong:** "Run `vcluster create my-vcluster` to create your first cluster."
  **Right:** "You need an isolated Kubernetes environment that doesn't affect the host. What tools do you have available, and how might you create one?"

- **Wrong:** "Add `sync.toHost.customResources` to your vcluster.yaml."
  **Right:** "Your vCluster can't see the host's CRDs, and your workload depends on a custom resource. Where would you configure what gets synced between clusters?"

- **Wrong:** "Set up a GitHub Actions workflow with `vcluster create` in the setup step and `vcluster delete` in the cleanup step."
  **Right:** "Every PR needs its own isolated cluster that disappears when merged. What would that lifecycle look like, and what triggers each phase?"