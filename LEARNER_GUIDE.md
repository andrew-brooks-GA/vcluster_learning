# Learner Guide — How This Curriculum Works

This document explains the teaching approach behind the vCluster curriculum so you know what to expect and why the mentor behaves the way it does. **Read this before your first session.**

---

## The Core Philosophy

This curriculum is built around a single idea: **you learn more from figuring things out than from being told the answer.** That sounds obvious, but it has real consequences for how the mentor interacts with you.

Research on AI-assisted learning suggests that learners who engage conceptually with a problem retain significantly more than those who delegate the problem to the AI. The friction you feel when you're stuck is not a bug — it's the learning. The mentor's job is to illuminate that friction, not remove it.

This doesn't mean the mentor withholds everything. Explanations of Kubernetes concepts, vCluster internals, or the purpose of a tool are fine. Pointing to official docs is fine. What the mentor avoids is making design choices for you or handing you the exact CLI commands, vcluster.yaml keys, or YAML structures you were meant to discover — because those are the moments where real understanding forms.

---

## The Socratic Method

The mentor asks questions rather than giving answers when you're working through design or architecture decisions about your vCluster setup. This is deliberate.

**What this looks like in practice:**
- You propose an approach → the mentor asks what problem it solves, or what happens when the host cluster restarts, or what the blast radius is
- You make a correct observation → the mentor asks you to reason through the next step, rather than confirming and filling in the rest
- You're stuck → the mentor drops to a more concrete hint, but still asks you to apply it

**What to do when you want a direct answer:**
Say **"just tell me."** The mentor will give you the information. The Socratic approach is a default, not a prison. You are in control.

**What the mentor avoids:**
- Confirming your observation and then listing all the configuration details that follow
- Naming the exact vcluster.yaml keys, CLI flags, or Helm values you should discover through milestone work
- Making the infrastructure design choice for you and explaining why it's correct
- Generic questions that don't reference your specific system and milestone

---

## Self-Regulated Learning (SRL)

At each milestone, the mentor follows a three-phase cycle based on Zimmerman's Self-Regulated Learning framework. This creates a reference point before you start and forces reflection when you finish.

### Forethought (before you start)
Before you create the first vCluster or edit the first YAML file, the mentor may ask:
- "What do you think will be the hardest part of this milestone?"
- "What's your plan for tackling it first?"

This is not a quiz. It creates a prediction you can compare against later. Learners who make explicit predictions before starting learn more than those who just dive in.

### Performance Monitoring (mid-milestone)
At some point while you're working, the mentor may ask:
- "Is this going the way you expected?"
- "What has surprised you so far?"

This surfaces course corrections while they're still cheap.

### Self-Reflection (after milestone)
Before moving to the next milestone, the mentor asks:
- "What would you do differently if you started over?"
- "What did you learn that you didn't expect to learn?"

And three self-assessment questions:
1. **Design confidence**: "Could you make the major design decisions again without help?"
2. **Implementation confidence**: "Could you configure it from scratch?"
3. **Concept transfer**: "Could you apply the main concept to a different project?"

These are answered on a scale of yes / mostly / not yet. They're not graded — they're for your own self-awareness and to calibrate how the mentor supports you going forward.

---

## Scaffolding Levels

The mentor adjusts how much support it gives based on where you are. This is based on Vygotsky's Zone of Proximal Development — the idea that the best learning happens just at the edge of what you can do on your own.

| Level | Description | When used |
|-------|-------------|-----------|
| **4** | Open Socratic question | You have the knowledge; just need a nudge |
| **3** | Targeted question pointing to the relevant area | You have the concept but haven't applied it here |
| **2** | Category hint — names the type of problem | You don't yet recognize the problem category |
| **1** | Concrete hint pointing to the specific mechanism | After struggling across multiple exchanges |
| **0** | Explanation with a worked example (never your actual fix) | Stuck on a prerequisite concept, clear frustration |

The mentor defaults to Level 2–3 during Project 1 (First Contact), where you're establishing basic familiarity. It drops lower when you're stuck and rises as you demonstrate mastery.

**The Fade Protocol:** Once you've shown command of a concept (e.g., how context switching works between host and virtual clusters), the mentor reduces support on the next encounter. This is intentional. If it drops too fast, say so.

---

## Concept Proficiency Tracking

The mentor tracks which concepts you've encountered and how much scaffolding you needed. This is stored in `LEARNER_STATE.md` and persists across sessions.

Proficiency levels (0–3):
- **0**: First encounter, needed significant guidance
- **1**: Needed moderate guidance, got there with prompting
- **2**: Needed targeted hints, arrived with Socratic questions
- **3**: Demonstrated independent command; applied without prompting

There are two tracked tables:
- **Kubernetes Prerequisites** — Pod, Service, Namespace, ConfigMap, Secret, RBAC, Deployment, etc. Skip-eligible at higher autonomy levels because they're foundational.
- **Concept Proficiency** — vCluster-specific concepts (syncer, control plane, CRD syncing, topology choice, etc.). Always goes through the Socratic pipeline regardless of recorded level, because vCluster behavior often differs from naive Kubernetes intuition.

This tracking means the mentor doesn't treat you the same in Project 4 as it did in Project 1 on concepts you've already mastered. New concepts always start with appropriate scaffolding even if your overall autonomy level is high.

---

## Global Autonomy Level

Separate from individual concept proficiency, the mentor tracks your overall autonomy level across the curriculum. This updates at project boundaries (e.g., First Contact → Under the Hood).

- **Level 1 (Operator-in-Training)**: Full Socratic pipeline on all design questions
- **Level 2 (Platform Operator)**: Pipeline relaxes for mastered Kubernetes core resources; still applies to all vCluster-specific concepts
- **Level 3 (Platform Engineer)**: Direct answers appropriate for mastered concepts; pipeline still applies to new concepts and first encounters

You start at Level 1.

---

## Lifecycle Threads

Running alongside the infrastructure milestones are three threads that surface software-craft topics through questions tied to a moment of natural pressure:

**Version control (git):** Introduced when you have working configuration worth preserving. Progresses from "how do you get back to this known-good state?" → branching for experiments → commit messages as documentation → tagging releases.

**Infrastructure as Code (IaC):** Introduced when you're repeating the same CLI commands and your cluster state starts drifting from your intent. Progresses from "how does your cluster describe itself?" → vcluster.yaml mastery → GitOps reconciliation.

**Testing:** Introduced when a silent misconfiguration bites you. Progresses from "how would you know if the syncer stopped working?" → declarative assertions → failure-injection drills.

These are never commands ("run `git init`" or "write this test"). They're always questions tied to a moment of natural pressure.

---

## Productive Struggle

When you're stuck, the instinct is to ask for the answer. That instinct is worth examining.

The mentor will meet you where you are and drop scaffolding as needed. But there's a zone of struggle that's actually productive — where you're working at the edge of your understanding. That's where the most durable learning happens.

If you feel stuck, say **what you've tried and where it broke**. The mentor will give you a targeted hint. If you're genuinely frustrated, say so — the mentor reads that and responds differently.

If you want a direct answer, ask for it. **"Just tell me"** is always honored.

---

## What the Mentor Tracks

`LEARNER_STATE.md` (in the repo root) contains:
- Current milestone and phase
- Global Autonomy Level
- Kubernetes Prerequisites table (for skip-eligibility at higher autonomy)
- Concept Proficiency table with scaffolding levels and last-seen dates
- Your self-assessment scores per milestone
- Scaffolding notes for the current project

If you create a project directory with a `DESIGN.md` file, the mentor will treat it as authoritative — it won't ask you to re-derive design decisions already recorded there. Using DESIGN.md is optional; it becomes useful when a project has enough design state that re-deriving it in each session would waste time.

The state file and any DESIGN.md are injected into context at the start of each conversation so the mentor picks up where you left off.

---

## A Note on Tooling Paths

This curriculum has two paths documented in the README: **Notion only** (self-paced) and **Notion + Git + Claude Code** (AI mentor). This guide describes the AI mentor path. If you're on the Notion-only path, the Socratic prompts in each milestone (in `complete_learning_path.md`) still apply — you're just asking them of yourself rather than having a mentor surface them.
