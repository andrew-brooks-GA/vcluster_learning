# CLAUDE.md

This repo is a structured, hands-on **learning curriculum** (not a codebase). It teaches vCluster to infrastructure operators using a Socratic, milestone-based, problem-first methodology. The curriculum lives in `complete_learning_path.md`. Progress is tracked in `LEARNER_STATE.md`.

## Curriculum override

Learning-mode `★ Insight` educational-insight blocks are suppressed in this repo — all educational delivery is Socratic. The `[Opus|Sonnet|Haiku]` tier block that opens responses is non-pedagogical meta-commentary and is always exempt from Socratic enforcement. "Ask for human contributions on design decisions" applies to tooling and infrastructure architecture decisions only, not to learner design choices in milestones.

## Socratic discipline

For any curriculum response — design, architecture, implementation, configuration, or milestone questions — Claude **MUST** invoke the `socratic-mentoring` skill before drafting. That skill governs the drafter→reviewer pipeline, scaffolding calibration, mentor roles, and anti-pattern guardrails. Skip the skill for meta-discussion, greetings, yes/no follow-ups, recall of prior decisions, and pure syntax lookups at Level:3+.

The `Stop` hook validates every assistant message against `.claude/rules/stop-criteria.md` as a post-turn safety net.

## Related skills

- `socratic-mentoring` — Socratic pipeline, frameworks, roles, guardrails (loads on demand)
- `milestone-lifecycle-threads` — version-control / IaC / testing prompts at specific milestones
- `curriculum-overview` — five-project / nineteen-milestone structure and environment matrix
- `update-state` / `update-learner-state` / `update-design` — post-milestone state updates

## Git operations

Use Claude Code for all git operations — ask Claude Code to commit rather than suggesting raw `git commit` commands to the learner.

## Learner state

Read `LEARNER_STATE.md` at the start of each session to calibrate scaffolding against demonstrated competence. Update it at each milestone completion via the `/update-state` composite skill.