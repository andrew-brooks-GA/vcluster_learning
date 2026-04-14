# vCluster Learning Roadmap

Mermaid diagrams optimized for Notion. Paste each fenced block into a Notion code block with language set to `mermaid`.

---

## Overview

```mermaid
flowchart TD
    P1["<b>Project 1: First Contact</b>\n<i>local | OSS + Free</i>\nA cluster inside a cluster — basic lifecycle"]
    P2["<b>Project 2: Under the Hood</b>\n<i>local | OSS + Free</i>\nSyncer, control plane, networking, CRDs"]
    P3["<b>Project 3: Configuration & Access</b>\n<i>local to cloud | OSS + Free</i>\nvcluster.yaml, access methods, governance"]
    P4["<b>Project 4: Production Readiness</b>\n<i>cloud | OSS + Free + Enterprise</i>\nTopologies, stateful, security, HA, lifecycle"]
    P5["<b>Project 5: Ecosystem Integration</b>\n<i>cloud | OSS + Free</i>\nCI/CD, GitOps, multi-tenancy, platform building"]

    P1 --> P2 --> P3 --> P4 --> P5

    style P1 fill:#e8eaf6,stroke:#3f51b5,color:#1a237e
    style P2 fill:#e8eaf6,stroke:#3f51b5,color:#1a237e
    style P3 fill:#e8eaf6,stroke:#3f51b5,color:#1a237e
    style P4 fill:#e8eaf6,stroke:#3f51b5,color:#1a237e
    style P5 fill:#e8eaf6,stroke:#3f51b5,color:#1a237e
```

---

## Lifecycle Threads — Full Progression

These three threads run parallel to the vCluster milestones. They are independent skills — you can learn vCluster without them, but production operators need all three.

```mermaid
flowchart TD
    subgraph vc["Version Control"]
        direction TB
        VC1["P1-M1: Reproduce this\nenvironment from memory?"]
        VC2["P2-M3: Configs accumulating —\ntrack what changed and why?"]
        VC3["P3-M1: Two people editing\nvcluster.yaml — now what?"]
        VC4["P4-M4: Monitoring configs\nversioned or not?"]
        VC5["P5-M2: Entire platform in git —\nwhat's the repo structure?"]
        VC1 --> VC2 --> VC3 --> VC4 --> VC5
    end

    subgraph iac["Infrastructure as Code"]
        direction TB
        IAC1["P1-M2: UI clicks —\nreproducible?"]
        IAC2["P2-M1: CLI flags —\nwritten down?"]
        IAC3["P2-M4: Custom sync config —\nsurvives delete/recreate?"]
        IAC4["P3-M3: Templates are policy —\nwhere outside the UI?"]
        IAC5["P4-M1: Three topologies —\nhow to manage at scale?"]
        IAC6["P4-M5: Lifecycle policies —\nconsistent across teams?"]
        IAC1 --> IAC2 --> IAC3 --> IAC4 --> IAC5 --> IAC6
    end

    subgraph test["Testing / Validation"]
        direction TB
        T1["P1-M3: Verified isolation once —\nprove it every time?"]
        T2["P2-M2: Checked three tiers —\nminimal automated check?"]
        T3["P3-M2: Three access methods —\nverify all still work?"]
        T4["P4-M2: DB survived restart —\nrepeatable guarantee?"]
        T5["P4-M3: Security policies —\nstill blocking after upgrade?"]
        T6["P5-M3: Shared change —\nbreak a tenant?"]
        T1 --> T2 --> T3 --> T4 --> T5 --> T6
    end

    VC1:::vcNode
    VC2:::vcNode
    VC3:::vcNode
    VC4:::vcNode
    VC5:::vcNode
    IAC1:::iacNode
    IAC2:::iacNode
    IAC3:::iacNode
    IAC4:::iacNode
    IAC5:::iacNode
    IAC6:::iacNode
    T1:::testNode
    T2:::testNode
    T3:::testNode
    T4:::testNode
    T5:::testNode
    T6:::testNode

    classDef vcNode fill:#e8f5e9,stroke:#4caf50,color:#1b5e20
    classDef iacNode fill:#e3f2fd,stroke:#2196f3,color:#0d47a1
    classDef testNode fill:#fff3e0,stroke:#ff9800,color:#e65100

    style vc fill:#e8f5e9,stroke:#4caf50,color:#1b5e20
    style iac fill:#e3f2fd,stroke:#2196f3,color:#0d47a1
    style test fill:#fff3e0,stroke:#ff9800,color:#e65100
```

---

## Project 1: First Contact

```mermaid
flowchart TD
    subgraph p1["Project 1: First Contact — local | OSS + Free"]
        direction TB

        M1["<b>M1: Basic Lifecycle</b> OSS\nCreate, connect, deploy,\nobserve host, delete"]
        M2["<b>M2: Platform UI</b> Free\nSame result, different path —\nwhen does each make sense?"]
        M3["<b>M3: Multi-Cluster Isolation</b> OSS\nTwo clusters, one host —\nwhat actually separates them?"]

        M1 --> M2 --> M3
    end

    VC1("Version Control\nCan you reproduce this\nenvironment tomorrow?"):::vc
    IAC1("Infrastructure as Code\nUI clicks aren't\nreproducible — now what?"):::iac
    T1("Testing\nVerified once manually —\nhow about every time?"):::test

    M1 -.- VC1
    M2 -.- IAC1
    M3 -.- T1

    classDef ms fill:#ffffff,stroke:#9e9e9e,color:#212121
    classDef vc fill:#e8f5e9,stroke:#4caf50,color:#1b5e20
    classDef iac fill:#e3f2fd,stroke:#2196f3,color:#0d47a1
    classDef test fill:#fff3e0,stroke:#ff9800,color:#e65100
    M1:::ms
    M2:::ms
    M3:::ms
    style p1 fill:#f5f5f5,stroke:#9e9e9e,color:#424242
```

**Progress:** `○ M1` → `○ M2` → `○ M3`

---

## Project 2: Under the Hood

```mermaid
flowchart TD
    subgraph p2["Project 2: Under the Hood — local | OSS + Free"]
        direction TB

        M1["<b>M1: Control Plane Config</b> OSS+Free\nBacking stores: SQLite vs etcd —\nwhat does your workload need?"]
        M2["<b>M2: Syncer Deep Dive</b> OSS\nMulti-tier app — trace what syncs,\nwhat rewrites, what disappears"]
        M3["<b>M3: Networking</b> OSS\nDNS resolution, cross-tier comms,\ningress — where do requests go?"]
        M4["<b>M4: Custom Resource Syncing</b> Free\nCRDs across the boundary —\nwho owns the contract?"]

        M1 --> M2 --> M3 --> M4
    end

    IAC1("IaC\nTwo configs, different flags —\nwritten down anywhere?"):::iac
    T1("Testing\nThree tiers checked manually —\nminimal automated check?"):::test
    VC1("Version Control\nConfigs accumulating —\ntrack what changed and why?"):::vc
    IAC2("IaC\nCustom sync config —\nsurvives delete and recreate?"):::iac

    M1 -.- IAC1
    M2 -.- T1
    M3 -.- VC1
    M4 -.- IAC2

    classDef ms fill:#ffffff,stroke:#9e9e9e,color:#212121
    classDef vc fill:#e8f5e9,stroke:#4caf50,color:#1b5e20
    classDef iac fill:#e3f2fd,stroke:#2196f3,color:#0d47a1
    classDef test fill:#fff3e0,stroke:#ff9800,color:#e65100
    M1:::ms
    M2:::ms
    M3:::ms
    M4:::ms
    style p2 fill:#f5f5f5,stroke:#9e9e9e,color:#424242
```

**Progress:** `○ M1` → `○ M2` → `○ M3` → `○ M4`

---

## Project 3: Configuration & Access

```mermaid
flowchart TD
    subgraph p3["Project 3: Configuration & Access — local to cloud | OSS + Free"]
        direction TB

        M1["<b>M1: vcluster.yaml Mastery</b> OSS\nOne file, sole source of truth —\nwhat to configure vs leave default?"]
        M2["<b>M2: Access Patterns</b> OSS\nThree access methods, three tradeoffs —\nwhich for a teammate vs a CI job?"]
        M3["<b>M3: Platform Governance</b> Free\nTemplates enforce consistency —\nbut consistency for whom?"]

        M1 --> M2 --> M3
    end

    VC1("Version Control\nTwo people editing vcluster.yaml —\nhow do you manage that?"):::vc
    T1("Testing\nThree access methods —\nverify all still working?"):::test
    IAC1("IaC\nTemplates are policy —\nwhere do they live outside the UI?"):::iac

    M1 -.- VC1
    M2 -.- T1
    M3 -.- IAC1

    classDef ms fill:#ffffff,stroke:#9e9e9e,color:#212121
    classDef vc fill:#e8f5e9,stroke:#4caf50,color:#1b5e20
    classDef iac fill:#e3f2fd,stroke:#2196f3,color:#0d47a1
    classDef test fill:#fff3e0,stroke:#ff9800,color:#e65100
    M1:::ms
    M2:::ms
    M3:::ms
    style p3 fill:#f5f5f5,stroke:#9e9e9e,color:#424242
```

**Progress:** `○ M1` → `○ M2` → `○ M3`

---

## Project 4: Production Readiness

```mermaid
flowchart TD
    subgraph p4["Project 4: Production Readiness — cloud | OSS + Free + Enterprise"]
        direction TB

        M1["<b>M1: Deployment Topologies</b> OSS+Free\nShared vs dedicated vs virtual nodes —\nbudget vs SLA"]
        M2["<b>M2: Stateful Workloads</b> OSS\nDB inside vCluster — prove data\nsurvives pod, control plane, node failures"]
        M3["<b>M3: Security Hardening</b> OSS\nRBAC, PSS, NetworkPolicy —\nwhere is the real boundary?"]
        M4["<b>M4: Observability & Ops</b> OSS+Free\nMetrics, logs, HA, recovery —\nknow before your users do"]
        M5["<b>M5: Lifecycle Management</b> Enterprise\nSleep, wake, auto-delete —\ncost vs destroying work"]

        M1 --> M2 --> M3 --> M4 --> M5
    end

    IAC1("IaC\nThree topologies —\nhow to manage at scale?"):::iac
    T1("Testing\nDB survived restart —\nrepeatable guarantee?"):::test
    T2("Testing\nSecurity policies —\nstill blocking after upgrade?"):::test
    VC1("Version Control\nMonitoring and alert configs —\nversioned?"):::vc
    IAC2("IaC\nLifecycle policies —\nconsistent across teams?"):::iac

    M1 -.- IAC1
    M2 -.- T1
    M3 -.- T2
    M4 -.- VC1
    M5 -.- IAC2

    classDef ms fill:#ffffff,stroke:#9e9e9e,color:#212121
    classDef vc fill:#e8f5e9,stroke:#4caf50,color:#1b5e20
    classDef iac fill:#e3f2fd,stroke:#2196f3,color:#0d47a1
    classDef test fill:#fff3e0,stroke:#ff9800,color:#e65100
    M1:::ms
    M2:::ms
    M3:::ms
    M4:::ms
    M5:::ms
    style p4 fill:#f5f5f5,stroke:#9e9e9e,color:#424242
```

**Progress:** `○ M1` → `○ M2` → `○ M3` → `○ M4` → `○ M5`

---

## Project 5: Ecosystem Integration

```mermaid
flowchart TD
    subgraph p5["Project 5: Ecosystem Integration — cloud | OSS + Free"]
        direction TB

        M1["<b>M1: CI/CD Pipelines</b> OSS\nEphemeral cluster per PR —\ncreate, test, destroy on merge"]
        M2["<b>M2: GitOps</b> OSS\nGit is the source of truth —\nbut clusters are ephemeral"]
        M3["<b>M3: Multi-Tenancy Platform</b> Free\nYou're the platform team now —\nyour users are your customers"]
        M4["<b>M4: Advanced Operations</b> OSS+Free\nPick 2: plugins, GPU, distro\nmigration, or cloud-native integrations"]

        M1 --> M2 --> M3 --> M4
    end

    ALL1("All Three Threads\nCI creates infra, deploys code,\nruns tests — all in one workflow"):::all
    IAC1("IaC\nEntire platform in git —\nwhat's the repo structure?"):::iac
    T1("Testing\nShared change affects all tenants —\nhow to test that?"):::test
    ALL2("All Three Threads\nExtensions are custom infra —\nbuild artifacts, config, and tests"):::all

    M1 -.- ALL1
    M2 -.- IAC1
    M3 -.- T1
    M4 -.- ALL2

    classDef ms fill:#ffffff,stroke:#9e9e9e,color:#212121
    classDef vc fill:#e8f5e9,stroke:#4caf50,color:#1b5e20
    classDef iac fill:#e3f2fd,stroke:#2196f3,color:#0d47a1
    classDef test fill:#fff3e0,stroke:#ff9800,color:#e65100
    classDef all fill:#fce4ec,stroke:#e91e63,color:#880e4f
    M1:::ms
    M2:::ms
    M3:::ms
    M4:::ms
    style p5 fill:#f5f5f5,stroke:#9e9e9e,color:#424242
```

**Progress:** `○ M1` → `○ M2` → `○ M3` → `○ M4`

---

## Legend

| Symbol | Meaning |
|--------|---------|
| `○` | Not started |
| `◐` | In progress |
| `●` | Complete |
| Green nodes | Version Control thread |
| Blue nodes | Infrastructure as Code thread |
| Orange nodes | Testing / Validation thread |
| Pink nodes | All three threads converge |
| Dotted lines | Lifecycle thread activates at this milestone |

---

## Progress Tracker

| Project | Milestones | Status |
|---------|-----------|--------|
| 1 — First Contact | M1 M2 M3 | `○ ○ ○` |
| 2 — Under the Hood | M1 M2 M3 M4 | `○ ○ ○ ○` |
| 3 — Configuration & Access | M1 M2 M3 | `○ ○ ○` |
| 4 — Production Readiness | M1 M2 M3 M4 M5 | `○ ○ ○ ○ ○` |
| 5 — Ecosystem Integration | M1 M2 M3 M4 | `○ ○ ○ ○` |

| Thread | Activations |
|--------|------------|
| Version Control | P1-M1 → P2-M3 → P3-M1 → P4-M4 → P5-M2 |
| Infrastructure as Code | P1-M2 → P2-M1 → P2-M4 → P3-M3 → P4-M1 → P4-M5 |
| Testing / Validation | P1-M3 → P2-M2 → P3-M2 → P4-M2 → P4-M3 → P5-M3 |