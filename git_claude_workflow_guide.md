# Git + Claude Code Workflow Guide

This is an operational supplement for learners using Git and Claude Code alongside the Notion curriculum. It covers setup, repo structure, and how Claude Code fits into the learning workflow.

**This is not a standalone curriculum.** All milestones, requirements, pressures, and verification steps live in the Notion workspace (see `notion_curriculum_guide.md`). This guide covers only the additional tooling layer.

---

## Prerequisites

Before starting, install:

| Tool | Installation |
|------|-------------|
| Git | https://git-scm.com/downloads |
| Claude Code CLI | Follow the instructions at https://claude.ai/code |

Then clone the curriculum repository:

```
git clone <repository-url>
cd vcluster_learning
```

---

## Repo Structure

| File / Directory | Purpose | Notion Equivalent |
|------------------|---------|-------------------|
| `complete_learning_path.md` | Canonical curriculum source -- all milestones, requirements, pressures | Milestones database |
| `roadmap.md` | Visual roadmap with Mermaid diagrams | Roadmap page |
| `LEARNER_STATE.md` | Your progress, concept proficiency, self-assessments | Milestones database Status + self-assessment properties |
| `notion_curriculum_guide.md` | Notion workspace setup instructions | (the Notion workspace itself) |
| `CLAUDE.md` | Instructions for Claude Code -- not learner-facing | (no equivalent) |
| `.claude/rules/` | Socratic teaching methodology rules | Static reflection prompts in milestone pages |
| `.claude/hooks/` | Session automation scripts | (no equivalent) |
| `.claude/skills/` | Claude Code skill definitions (commit, state updates) | (no equivalent) |
| `.claude/settings.json` | Claude Code configuration | (no equivalent) |

**Files you maintain:** `LEARNER_STATE.md` (updated by Claude Code on your behalf), and any vcluster.yaml and project files you create during milestones. Organize milestone work in project directories (e.g., `project-1/`, `project-2/`). The curriculum does not prescribe a rigid structure -- you will discover what organization works as part of the learning process.

**Files you do not need to touch:** Everything in `.claude/`, `CLAUDE.md`, `complete_learning_path.md`, `roadmap.md`. These are maintained by the curriculum author.

---

## What Claude Code Provides

### Socratic Mentoring

Claude Code acts as an infrastructure mentor. When you ask questions about design, architecture, or implementation, it responds with guiding questions rather than direct answers. This is deliberate -- the curriculum is designed around learning through discovery.

What this looks like in practice:
- You ask: "How should I configure sync rules for my CRD?"
- Claude Code responds with questions about what your CRD needs, what happens at the sync boundary, and what tradeoffs you're making
- You reason through the answer and arrive at your own configuration

Claude Code will give direct answers for factual/syntax questions (e.g., "what's the YAML key for resource limits?") once you've demonstrated competence with a concept.

### Scaffolding Calibration

Claude Code adjusts the difficulty of its questions based on your demonstrated skill level. Early in the curriculum, it provides more structured guidance. As you demonstrate mastery, it steps back and asks broader, more open-ended questions.

This calibration is tracked in `LEARNER_STATE.md` and carries across sessions.

### Progress Tracking

At milestone completion, Claude Code:
1. Reviews your work against the milestone requirements
2. Asks you to self-assess (design confidence, implementation confidence, transfer confidence -- each 1-5)
3. Records concept proficiency observations in `LEARNER_STATE.md`
4. Updates your current position in the curriculum

### Session Continuity

When you start a new Claude Code session, it reads `LEARNER_STATE.md` to understand:
- Which milestone you're working on
- Your concept proficiency levels
- Your scaffolding calibration
- Previous self-assessments

This means you can pick up where you left off without re-explaining your progress.

---

## Key Workflows

### Starting a Session

Open your terminal in the repo directory and start Claude Code. It will automatically read your state and orient itself. No special commands needed.

> **Note:** Session automation relies on bash-compatible hook scripts in `.claude/settings.json`. If you are on Windows, use Git Bash, WSL, or another bash-compatible shell. PowerShell alone will not run the session hooks.

### Working on a Milestone

1. Open your Notion milestone page for context (requirements, pressures, verification)
2. Work through the milestone, asking Claude Code questions as they arise
3. Claude Code will guide you through design decisions and point you toward areas to explore
4. Create your configuration files and manifests in the repo as you work

### Completing a Milestone

When you believe you've met all requirements:
1. Share your configuration or kubectl output with Claude Code
2. It will review against the milestone requirements
3. It will run the self-assessment prompts
4. It will update `LEARNER_STATE.md` with your results
5. Update your Notion milestone status to "Complete" manually

### Committing Your Work

Use `/commit` through Claude Code for all git operations. Do not use raw `git commit` commands. This ensures consistent commit messages and avoids accidental commits of sensitive files (kubeconfigs, credentials).

---

## What Claude Code Will NOT Do

- **Write your configurations for you.** It will help you reason through the design, but the YAML is yours to write.
- **Give direct answers to design questions.** If you ask "what topology should I use?", it will ask you about your constraints and help you reason to an answer.
- **Skip the reflection cycle.** Milestone self-assessments happen at every completion, even when you're eager to move on.
- **Bypass the pressures.** The "pressure you'll feel" sections name concepts you're meant to struggle with. Claude Code will not shortcut past them.

---

## Keeping Notion and Git in Sync

The Notion workspace and the Git repo track progress independently:

| What | Notion | Git repo |
|------|--------|----------|
| Milestone status | Milestones database Status property | `LEARNER_STATE.md` Current Position |
| Self-assessments | Milestones database confidence properties | `LEARNER_STATE.md` Self-Assessments table |
| Concept proficiency | (not tracked) | `LEARNER_STATE.md` Concept Proficiency table |
| Configuration files | (not stored) | Project directories in the repo |
| Notes and observations | Milestone page "My Notes" section | Commit messages and inline comments |

Update your Notion milestone status when Claude Code updates `LEARNER_STATE.md`. The two systems complement each other -- Notion is your visual dashboard, the repo is your working environment.
