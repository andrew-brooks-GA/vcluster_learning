---
name: milestone-lifecycle-threads
description: Surfaces version-control, Infrastructure-as-Code, and testing/validation pressure prompts at specific vCluster curriculum milestones. Use whenever a learner starts, mid-runs, or completes a milestone listed in the per-project matrix below (P1-M1, P1-M2, P1-M3, P2-M1 through P2-M4, P3-M1 through P3-M3, P4-M1 through P4-M5, P5-M1 through P5-M4). Do NOT use for general Socratic tutoring — that is the socratic-mentoring skill. These lifecycle threads are milestone-specific prompts, not every-turn rules.
---

# Lifecycle threads — version control / IaC / testing across milestones

Version control, Infrastructure as Code, and testing/validation are learning objectives — not chores to be handled for the learner. Apply the same Socratic method to these topics as to infrastructure concepts.

## When to use this skill

Only when entering, working inside, or exiting a milestone that appears in the thread matrix below. For general pedagogy, use `socratic-mentoring` instead.

## vCluster curriculum — three threads

### Thread 1: Version control (git)

- **P1-M1**: "You typed CLI commands to create, connect, and populate a cluster. If you closed this terminal, what would you need to remember to reproduce this environment tomorrow?" → *Capturing imperative steps as a reproducible record*
- **P2-M3**: "Your DNS config, ingress resources, and inter-service wiring are accumulating. You'll need to recreate this setup in Project 3 — what's your system for tracking what you configured and why?" → *Version history as architectural memory across projects*
- **P3-M1**: "This vcluster.yaml is your cluster's source of truth. What happens when two people need to change it? How do you know which version produced the cluster that's running right now?" → *Config as shared artifact: concurrent changes, provenance, review*
- **P4-M4**: "Your alerts, scrape configs, and backup jobs need to stay consistent across multiple vClusters. Which of those should be defined centrally, and how would you detect an unauthorized change?" → *Operational config as versioned infrastructure; drift detection for non-workload resources*
- **P5-M1**: (All threads — see below)
- **P5-M4**: (All threads — see below)

### Thread 2: Infrastructure as Code

- **P1-M2**: "You clicked through a UI to create a cluster. Could your teammate reproduce that cluster from your description — or is the cluster definition living only in the platform's database?" → *UI-created state vs declarative, portable definitions*
- **P2-M1**: "You created two clusters with different backing store configurations. Are those configurations written down, or do you remember the flags you passed?" → *CLI flags are ephemeral; the config file is the artifact*
- **P2-M4**: "Your sync configuration is now custom — it lives in a vcluster.yaml. If you delete this vCluster and recreate it without that file, the sync rules vanish. Where does that file live?" → *Config files as the authoritative record of sync behavior*
- **P3-M3**: "If three teams need the same base cluster with different limits and network rules, what should exist once as a platform definition and what should remain per-team?" → *Templates as infrastructure policy; separating shared definition from per-tenant variation*
- **P4-M1**: "You now have three distinct topology configurations. How do you manage these as your vCluster count grows from 3 to 30? Is topology a property of the vCluster config, the platform template, or something set at creation time?" → *Topology as codified platform decision vs per-cluster override*
- **P4-M5** (optional Enterprise): "Your lifecycle policies exist in the platform UI. If you rebuilt the platform from scratch, would these policies come back automatically? How do you apply them consistently across clusters provisioned by different teams?" → *Platform-level policy as code*
- **P5-M1**: (All threads — see below)
- **P5-M2**: "If git is the source of truth for cluster existence, what closes the gap between a commit landing and the host cluster reconciling without a human running the CLI?" → *Declarative cluster lifecycle: from committed state to running infrastructure without imperative intervention*
- **P5-M4**: (All threads — see below)

### Thread 3: Testing / validation

- **P1-M3**: "You verified isolation by checking manually — once. How do you prove it every time a config change is made? If someone changes the sync configuration tomorrow, what would break your manual check?" → *Manual verification as baseline; fragility of one-time checks*
- **P2-M2**: "You deployed a three-tier app and checked it manually. If someone changes the syncer config and PVCs stop syncing, how would you catch that before users do? What would a minimal automated check look like?" → *Scripted verification with assertions against syncer behavior*
- **[CI bridge — P2-M3]**: "You have a script that verifies your three-tier app is reachable. If you wanted that check to run automatically every time someone opens a pull request, what would need to change about how it's structured?" → *From manual script to CI-compatible test: exit codes, environment independence, no human presence*
- **P3-M2**: "You have three access methods and three kubeconfigs. How do you verify all three are still working after a config change? How do you verify the scoped kubeconfig actually can't escape its namespace?" → *Access-pattern regression testing; proving security constraints hold*
- **P4-M2**: "Your database survived a pod rescheduling — that's one data point. How do you turn that into a repeatable guarantee? What would a survival test look like that you could run before every storage config change?" → *Data-layer survival as a repeatable, pre-change gate*
- **P4-M3**: "You wrote security policies. How do you prove they still block what they should after the next vCluster version upgrade? A policy that was blocking correctly last week may not be blocking today." → *Security regression testing across version boundaries*
- **P5-M1**: (All threads — see below)
- **P5-M3**: "How would you deliver one shared platform-policy change to every tenant cluster without also causing a team-specific template change to rewrite already-running clusters?" → *Platform-level change isolation: shared policy rollout vs tenant-specific blast radius*
- **P5-M4**: (All threads — see below)

### All-threads milestones (version control + IaC + testing converge)

- **P5-M1**: "A pull request opens and needs an isolated cluster, then closes and the cluster should disappear. What events should drive creation and cleanup, and where should those rules live so the lifecycle is auditable?" → *CI pipeline as convergence point: the workflow file is version-controlled IaC that creates ephemeral infrastructure and runs tests — but the clusters it creates are not versioned. Auditability and pipeline-as-code testing.*
- **P5-M4**: "Your extensions, plugins, and integrations are custom infrastructure. The plugin image is a build artifact. The configuration is IaC. The 'does it still work after upgrade' question is a test. How do you manage all three for code you own but didn't write from scratch?" → *Custom extension lifecycle: build, declare, verify across vCluster upgrades*

## Lifecycle anti-patterns

- **Giving commands.** "Run `git init`" or "write a Helm values file" is solving for them. Ask what problem the tool solves.
- **Tool-leaking questions.** "Have you considered using ArgoCD?" is an answer in a question's clothing. Describe the problem instead.
- **Premature introduction.** Don't introduce GitOps before the learner has configs worth versioning.
- **Disconnected from context.** "You should write tests" teaches nothing. Connect to what they're building.
- **Repeating basics.** A learner in Production Readiness already knows how to commit. Advance to branching strategy, config versioning, or rollback procedures.
- **Suggesting raw git commands.** Always route git operations through Claude Code rather than giving raw commands.
