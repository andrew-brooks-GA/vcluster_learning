# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repository Is

A structured, hands-on learning curriculum — not a traditional codebase. It teaches vCluster (virtual Kubernetes clusters) to infrastructure operators using a Socratic, milestone-based, problem-first methodology.

The curriculum lives in `complete_learning_path.md` — 5 projects, 19 milestones, from first install to production platform engineering.

## Curriculum Override

Learning mode educational insight blocks (`★ Insight` blocks) are suppressed in this repo — all educational delivery is through Socratic questioning per `@.claude/rules/socratic-pipeline.md`. The `[Opus|Sonnet|Haiku]` tier block is non-pedagogical meta-commentary — it is always exempt from Socratic enforcement. "Ask for human contributions on design decisions" applies to tooling and infrastructure architecture decisions only, not to learner design choices in milestones.

## Repository Structure

- `complete_learning_path.md` — vCluster curriculum: projects, milestones, requirements, and pressures
- `roadmap.md` — Mermaid visual roadmap for the curriculum
- `LEARNER_STATE.md` — Learner progress tracking (scaffolding calibration, concept proficiency, self-assessments)

## Curriculum Overview

| Project | Focus | Environment |
|---------|-------|-------------|
| 1 — First Contact | Basic lifecycle, UI, isolation | local |
| 2 — Under the Hood | Control plane, syncer, networking, CRDs | local |
| 3 — Configuration & Access | vcluster.yaml, access patterns, governance | local → cloud |
| 4 — Production Readiness | Topologies, stateful, security, HA, lifecycle | cloud |
| 5 — Ecosystem Integration | CI/CD, GitOps, multi-tenancy, extensions | cloud |

## How to Assist in This Repo

- **Problem-first philosophy**: milestones describe *what the infrastructure must demonstrate*, not how. Do not hand the learner a complete configuration.
- **Each milestone builds on the last**: read the full project's milestone chain before advising on any single milestone.
- **"Pressure you'll feel" sections** are the pedagogical core: they identify the concept the learner is meant to struggle with. Don't shortcut past these.
- **Prefer incomplete examples over complete configs.** Drop-in configurations bypass the design thinking the milestone is meant to teach.
- **Use Claude Code for all git operations** — ask Claude Code to commit rather than suggesting raw `git commit` commands.

## Socratic Pipeline and Teaching Framework

All Socratic methodology, behavioral rules, mentor roles, and lifecycle thread guidance are defined in the rule files below. These are the authoritative sources — do not duplicate their content here.

@.claude/rules/socratic-pipeline.md
@.claude/rules/teaching-frameworks.md
@.claude/rules/mentor-roles.md
@.claude/rules/socratic-guardrails.md
@.claude/rules/lifecycle-threads.md

## Learner State Tracking

`LEARNER_STATE.md` tracks progress across sessions. **Read it at the start of each session** to calibrate scaffolding levels based on demonstrated competence rather than stage defaults.

**Update at each milestone completion** with:
- Concept proficiency observations (concept name, scaffolding level reached, notes)
- The learner's self-assessment ratings (design/implementation/transfer confidence)
- Current project and milestone

Use the `/update-state` composite skill (or `/update-learner-state` directly for state-only updates) to update the file.

## Environment by Project

| Project | Environment | Key tools/concerns |
|---------|-------------|--------------------|
| First Contact | Local (kind/minikube) | vCluster CLI, kubectl, contexts, Platform UI |
| Under the Hood | Local | Backing stores, syncer, DNS, CRDs, vcluster.yaml |
| Config & Access | Local → Cloud | YAML config, ingress, load balancers, kubeconfig, templates |
| Production Readiness | Cloud (EKS/GKE/AKS) | Node pools, PVCs, CSI, NetworkPolicies, Prometheus, Velero |
| Ecosystem Integration | Cloud | GitHub Actions, ArgoCD/Flux, multi-tenancy, plugins |

## When Project Directories Appear

As the learner works through milestones, project directories will be created containing vcluster.yaml files, Helm values, scripts, and CI/CD configurations. The curriculum's lifecycle pressure prompts guide the learner toward discovering project setup and config organization Socratically — don't preemptively set things up for them.
