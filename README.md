# vCluster Learning Curriculum

A hands-on, milestone-based curriculum for mastering [vCluster](https://www.vcluster.com/) -- from first install to production-grade platform engineering. 5 projects, 19 milestones, problem-first methodology.

## Who This Is For

Infrastructure operators and platform engineers who know Kubernetes basics (pods, deployments, services, namespaces) and want to learn virtual cluster architecture through guided, hands-on work.

## Working with the Mentor (read first)

If you're using the Claude Code path, the AI mentor teaches **Socratically** — it asks questions rather than handing you answers when you're working through design and configuration choices. The friction when you're stuck is not a bug; it's where the learning happens.

**What this means in practice:**
- The mentor won't give you the exact `vcluster.yaml` keys or CLI flags you're meant to discover through milestone work. It will help you reason toward them.
- Say **"just tell me"** at any time to get a direct answer. The Socratic default is a tool, not a constraint.
- When you're stuck, describe what you've tried and where it broke — the mentor responds better to specifics than to "I'm stuck."
- The mentor tracks which concepts you've mastered in `LEARNER_STATE.md` and adjusts how much support it gives accordingly.

**Before your first session, read [`LEARNER_GUIDE.md`](LEARNER_GUIDE.md)** — it explains the full methodology (Socratic method, SRL cycle, scaffolding levels, concept tracking, autonomy progression) in 5 minutes. This isn't optional reading; the mentor's behavior will feel strange without it.

If you're on the Notion-only path, the Socratic prompts live inline in each milestone — you ask them of yourself.

## Curriculum Overview

| Project | Focus | Environment |
|---------|-------|-------------|
| 1 -- First Contact | Basic lifecycle, UI, isolation | Local |
| 2 -- Under the Hood | Control plane, syncer, networking, CRDs | Local |
| 3 -- Configuration & Access | vcluster.yaml, access patterns, governance | Local to Cloud |
| 4 -- Production Readiness | Topologies, stateful, security, HA, lifecycle | Cloud |
| 5 -- Ecosystem Integration | CI/CD, GitOps, multi-tenancy, extensions | Cloud |

Each milestone describes **what your system must demonstrate**, not how to build it. You design the solution.

## Getting Started

Start with [`notion_curriculum_guide.md`](notion_curriculum_guide.md) -- it walks you through setting up the curriculum workspace and choosing your tooling path.

### Tooling Paths

| Path | What you use | Details |
|------|-------------|---------|
| **Notion only** | Notion workspace + CLI tools | All curriculum content, self-paced |
| **Notion + Git + Claude Code** | Above + Git repo + AI mentor | Adds Socratic mentoring, automated progress tracking, scaffolded guidance |

Both paths cover the same milestones and requirements. See [`git_claude_workflow_guide.md`](git_claude_workflow_guide.md) for the Git + Claude Code setup. Windows users should use Git Bash or WSL -- the Claude Code session hooks require a bash-compatible shell.

## Key Files

| File | Purpose |
|------|---------|
| [`LEARNER_GUIDE.md`](LEARNER_GUIDE.md) | **Read first (Claude Code path).** The teaching methodology: Socratic method, SRL cycle, scaffolding levels, concept tracking |
| [`NEXT_SESSION_CHECKLIST.md`](NEXT_SESSION_CHECKLIST.md) | Short checklist for resuming work after a break |
| [`notion_curriculum_guide.md`](notion_curriculum_guide.md) | Getting-started guide -- Notion workspace setup and choosing a tooling path |
| [`complete_learning_path.md`](complete_learning_path.md) | Canonical curriculum source -- all milestones, requirements, and pressures |
| [`roadmap.md`](roadmap.md) | Visual roadmap with Mermaid diagrams |
| [`git_claude_workflow_guide.md`](git_claude_workflow_guide.md) | Operational guide for Git + Claude Code users |
| [`scripts/notion_ai_prompts.md`](scripts/notion_ai_prompts.md) | Copy-paste prompts to build the Notion workspace using Notion AI |

## Tier System

| Tag | Meaning |
|-----|---------|
| `[OSS]` | vCluster open-source CLI only |
| `[Free]` | vCluster Platform free tier (loft.sh account required) |
| `[Optional -- Enterprise]` | Enterprise features; optional bonus content |

The standard curriculum ceiling is OSS + Free. Enterprise appears only as optional bonus content in P4-M5. The curriculum works without a Platform account -- skip `[Free]` milestones for an OSS-only track.

## License

This work is licensed under the [MIT License](LICENSE).
