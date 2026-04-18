---
name: curriculum-overview
description: Describes the five-project / nineteen-milestone vCluster curriculum structure, environment-by-project matrix, and problem-first pedagogical philosophy. Use when a learner asks about overall curriculum shape, how projects relate, what comes next after a given project, or which environment (local vs cloud) a milestone requires. Not needed for within-milestone work — socratic-mentoring handles that.
---

# vCluster curriculum — overview

The curriculum lives in `complete_learning_path.md` at the repo root — 5 projects, 19 milestones, from first install to production platform engineering.

## Project matrix

| Project | Focus | Environment |
|---------|-------|-------------|
| 1 — First Contact | Basic lifecycle, UI, isolation | local |
| 2 — Under the Hood | Control plane, syncer, networking, CRDs | local |
| 3 — Configuration & Access | vcluster.yaml, access patterns, governance | local → cloud |
| 4 — Production Readiness | Topologies, stateful, security, HA, lifecycle | cloud |
| 5 — Ecosystem Integration | CI/CD, GitOps, multi-tenancy, extensions | cloud |

## Environment and key concerns

| Project | Environment | Key tools/concerns |
|---------|-------------|--------------------|
| First Contact | Local (kind/minikube) | vCluster CLI, kubectl, contexts, Platform UI |
| Under the Hood | Local | Backing stores, syncer, DNS, CRDs, vcluster.yaml |
| Config & Access | Local → Cloud | YAML config, ingress, load balancers, kubeconfig, templates |
| Production Readiness | Cloud (EKS/GKE/AKS) | Node pools, PVCs, CSI, NetworkPolicies, Prometheus, Velero |
| Ecosystem Integration | Cloud | GitHub Actions, ArgoCD/Flux, multi-tenancy, plugins |

## How to assist in this repo

- **Problem-first philosophy**: milestones describe *what the infrastructure must demonstrate*, not how. Do not hand the learner a complete configuration.
- **Each milestone builds on the last**: read the full project's milestone chain before advising on any single milestone.
- **"Pressure you'll feel" sections** are the pedagogical core: they identify the concept the learner is meant to struggle with. Don't shortcut past these.
- **Prefer incomplete examples over complete configs.** Drop-in configurations bypass the design thinking the milestone is meant to teach.

## When project directories appear

As the learner works through milestones, project directories will be created containing vcluster.yaml files, Helm values, scripts, and CI/CD configurations. The curriculum's lifecycle pressure prompts guide the learner toward discovering project setup and config organization Socratically — don't preemptively set things up for them.

## Related files

- `complete_learning_path.md` — curriculum: projects, milestones, requirements, pressures
- `roadmap.md` — Mermaid visual roadmap
- `LEARNER_STATE.md` — progress tracking (scaffolding calibration, concept proficiency, self-assessments)
