# Notion AI Prompts -- vCluster Curriculum Workspace Setup

Run these prompts sequentially in Notion AI to build the complete curriculum workspace. Each prompt is copy-paste ready and self-contained.

**How to use:**
1. Create a new top-level page in Notion titled "vCluster Learning Curriculum"
2. Run each prompt in order using Notion AI (Agent mode)
3. After each phase, run the checkpoint prompt to verify
4. Finish with the manual checklist at the end

---

## Phase 1: Database Schemas

### Prompt 1 -- Projects Database

> **What to do:** Use "Build with AI" or Notion AI to create a new database.
> **Success:** A database named "Projects" with 4 typed properties.

```
Create a database called "Projects" with these exact properties:

- Title (title) -- the project name
- Focus (rich text) -- one-line description of the project
- Environment (select) -- options: "Local", "Cloud", "Local to Cloud"
- Tiers (multi-select) -- options: "OSS", "Free", "Enterprise"

Do not add any other properties. Use these exact property names.
```

---

### Prompt 2 -- Milestones Database

> **What to do:** Use "Build with AI" or Notion AI to create a new database.
> **Success:** A database named "Milestones" with 15 typed properties including a relation to Projects.

```
Create a database called "Milestones" with these exact properties:

- Title (title) -- the milestone name
- Project (relation to the "Projects" database)
- Milestone Number (select) -- options: "M1", "M2", "M3", "M4", "M5"
- Status (status) -- options: "Not Started", "In Progress", "Complete"
- Tier Required (select) -- options: "OSS", "Free", "Enterprise", "OSS + Free"
- Environment (select) -- options: "Local", "Cloud", "Local to Cloud"
- Cloud Required (checkbox)
- Optional (checkbox)
- Needs GitHub (checkbox)
- Previous Milestone (relation to this same "Milestones" database -- a self-relation)
- Lifecycle Thread (multi-select) -- options: "Version Control", "Infrastructure as Code", "Testing"
- Date Completed (date)
- Design Confidence (number)
- Implementation Confidence (number)
- Transfer Confidence (number)

Do not add any other properties. Use these exact property names and types.
```

---

### Prompt 3 -- Resources Database

> **What to do:** Use "Build with AI" or Notion AI to create a new database.
> **Success:** A database named "Resources" with 4 typed properties including a relation to Milestones.

```
Create a database called "Resources" with these exact properties:

- Title (title) -- the resource name
- URL (url) -- link to external documentation
- Related Milestones (relation to the "Milestones" database)
- What to Look For (rich text) -- brief description of why this resource matters

Do not add any other properties. Use these exact property names.
```

---

### Checkpoint 1

> **What to do:** Ask Notion AI to audit what was created.

```
List every database in this workspace and every property in each database, including the exact property name and type. Flag any property that could not be created or has the wrong type.
```

---

## Phase 2: Populate Entries

### Prompt 4 -- Projects Entries

> **What to do:** Ask Notion AI Agent to populate the Projects database.
> **Success:** 5 entries in the Projects database.

```
Add these 5 entries to the "Projects" database. Do not rename any existing properties.

1. Title: "Project 1: First Contact"
   Focus: "Basic lifecycle, UI, isolation"
   Environment: Local
   Tiers: OSS, Free

2. Title: "Project 2: Under the Hood"
   Focus: "Control plane, syncer, networking, CRDs"
   Environment: Local
   Tiers: OSS, Free

3. Title: "Project 3: Configuration & Access"
   Focus: "vcluster.yaml, access patterns, governance"
   Environment: Local to Cloud
   Tiers: OSS, Free

4. Title: "Project 4: Production Readiness"
   Focus: "Topologies, stateful, security, HA, lifecycle"
   Environment: Cloud
   Tiers: OSS, Free, Enterprise

5. Title: "Project 5: Ecosystem Integration"
   Focus: "CI/CD, GitOps, multi-tenancy, extensions"
   Environment: Cloud
   Tiers: OSS, Free
```

---

### Prompt 5 -- P1 Milestones (3 entries)

> **What to do:** Ask Notion AI Agent to create milestone entries with page body content.
> **Success:** 3 entries in Milestones for Project 1, each with full page content.

```
Add these 3 entries to the "Milestones" database. Set the Project relation to "Project 1: First Contact" for all three. Do not rename any existing properties.

Use this exact section structure for every milestone page body:
## Goal
## Requirements
## Pressure You'll Feel
## Lifecycle Pressure
## Verification
## Reference Links
## Reflection Prompts
## Self-Assessment (complete after finishing)
## My Notes

---

ENTRY 1:
Title: "M1: The Basic Lifecycle"
Milestone Number: M1
Status: Not Started
Tier Required: OSS
Environment: Local
Cloud Required: unchecked
Optional: unchecked
Needs GitHub: unchecked
Lifecycle Thread: Version Control
Previous Milestone: (none)

Page body:

## Goal
Install the vCluster CLI. Create a vCluster, connect to it, deploy a workload, observe how it appears on the host, and perform a clean deletion.

## Requirements
- vCluster CLI installed and `vcluster version` returns a version string
- A vCluster named `dev` created in a host namespace of your choice
- nginx Deployment running inside the virtual cluster (verified with `kubectl get pods` against the virtual context)
- The same Pod visible on the host cluster with a rewritten name (the vCluster syncer appends a suffix); names must not match between virtual and host
- `kubectl config get-contexts` shows both the host context and the vCluster context as distinct entries
- `vcluster delete dev` completes cleanly; the host namespace is absent afterward

## Pressure You'll Feel
You're running a cluster inside a cluster. When you type `kubectl`, which cluster are you talking to? The host and virtual contexts both look like normal Kubernetes clusters. A misrouted command in the wrong context is hard to notice and easy to make. What's your strategy for always knowing where your commands land?

## Lifecycle Pressure
**Thread:** Version Control
You just typed a sequence of CLI commands to create, connect, and populate a cluster. If you closed this terminal right now, what would you need to remember to reproduce this exact environment tomorrow? Is there anything you could write down that would make recreation mechanical rather than memorized?

## Verification
Inside virtual context: `kubectl get pods -n default`
Switch to host context: `kubectl config use-context <host>` then `kubectl get pods -n <vcluster-namespace>` -- the pod names here should contain the vCluster suffix, not the names you set.

## Reference Links
Architecture Overview: https://www.vcluster.com/docs/vcluster/introduction/architecture/
You just saw the syncer rewriting pod names. This document explains the design principles behind that behavior.

## Reflection Prompts
Before starting:
- What do you think will be the hardest part of this milestone?
- What approach are you planning to try first, and why?

Mid-milestone:
- Is this going the way you expected when you started?
- What has surprised you so far?

After completing:
- What would you do differently if you started this milestone over?
- What did you learn that you didn't expect to learn?

## Self-Assessment (complete after finishing)
- Design confidence (1-5): Could you make the major configuration decisions again without help?
- Implementation confidence (1-5): Could you reproduce this from scratch without notes?
- Transfer confidence (1-5): Could you apply the main pattern to a different but similar problem?

## My Notes
(Your free-form workspace)

---

ENTRY 2:
Title: "M2: Platform UI"
Milestone Number: M2
Status: Not Started
Tier Required: Free
Environment: Local
Cloud Required: unchecked
Optional: unchecked
Needs GitHub: unchecked
Lifecycle Thread: Infrastructure as Code
Previous Milestone: M1: The Basic Lifecycle

Page body:

## Goal
Install the vCluster Platform and create a vCluster through the web UI. Compare what the UI creates with what the CLI created in M1.

## Requirements
- vCluster Platform running locally
- Platform UI accessible in a browser; login works
- A vCluster created through the UI -- not the CLI
- The UI-created vCluster is functional: you can deploy a pod to it via kubectl
- Both the M1 CLI vCluster and the M2 UI vCluster are visible and distinguishable in the platform UI
- You can identify at least one configuration difference between what the UI defaults produced vs the CLI defaults from M1

## Pressure You'll Feel
The CLI and UI both create vClusters. For this milestone they produce the same result. But when does one make more sense than the other? Think about who the operator is, what their Kubernetes familiarity is, and whether the operation will happen once or a hundred times.

## Lifecycle Pressure
**Thread:** Infrastructure as Code
You clicked through a UI to create a cluster. Could your teammate reproduce that cluster from your description? Is there a way to capture what you configured -- or is the cluster definition living only in the platform's database?

## Verification
- Navigate to the platform UI and confirm both clusters are listed
- Click into the UI-created cluster; download its kubeconfig from the UI
- Use that kubeconfig to run `kubectl get nodes` -- one node should be returned

## Reference Links
What Are Virtual Clusters: https://www.vcluster.com/docs/vcluster/introduction/what-are-virtual-clusters
You've now created vClusters both ways. This explains the conceptual distinction this architecture is solving.

## Reflection Prompts
Before starting:
- What do you think will be the hardest part of this milestone?
- What approach are you planning to try first, and why?
Mid-milestone:
- Is this going the way you expected when you started?
- What has surprised you so far?
After completing:
- What would you do differently if you started this milestone over?
- What did you learn that you didn't expect to learn?

## Self-Assessment (complete after finishing)
- Design confidence (1-5): Could you make the major configuration decisions again without help?
- Implementation confidence (1-5): Could you reproduce this from scratch without notes?
- Transfer confidence (1-5): Could you apply the main pattern to a different but similar problem?

## My Notes
(Your free-form workspace)

---

ENTRY 3:
Title: "M3: Multi-Cluster Isolation"
Milestone Number: M3
Status: Not Started
Tier Required: OSS
Environment: Local
Cloud Required: unchecked
Optional: unchecked
Needs GitHub: unchecked
Lifecycle Thread: Testing
Previous Milestone: M2: Platform UI

Page body:

## Goal
Run two or more vClusters simultaneously on the same host. Deploy different workloads to each. Verify that resources in one cluster are invisible from the other.

## Requirements
- At least two vClusters running simultaneously: `team-a` and `team-b`
- Each vCluster has a distinct Deployment with a distinct image (e.g., nginx vs httpd)
- From within `team-a`'s context, `kubectl get pods --all-namespaces` returns no pods belonging to `team-b`'s workloads (and vice versa)
- Both vClusters are visible as separate namespaces on the host cluster
- A `kubectl get namespaces` inside either virtual cluster shows only the default set -- not the host's full namespace list

## Pressure You'll Feel
Both clusters share the same host nodes, the same CNI, and the same etcd (or SQLite). What exactly separates them? If the isolation is at the API server level, what reaches through that layer? What can a workload inside one vCluster observe about the other -- directly or indirectly?

## Lifecycle Pressure
**Thread:** Testing
You verified isolation by checking manually -- once. How do you prove it every time a config change is made? If someone changes the sync configuration tomorrow, what would break your manual check, and how would you know it broke?

## Verification
Switch to team-a context: `kubectl get pods --all-namespaces` -- team-b workloads must not appear.
Switch to team-b context: `kubectl get pods --all-namespaces` -- team-a workloads must not appear.
Switch to host context: `kubectl get namespaces` -- both vcluster namespaces should be present.

## Reference Links
(none for this milestone)

## Reflection Prompts
Before starting:
- What do you think will be the hardest part of this milestone?
- What approach are you planning to try first, and why?
Mid-milestone:
- Is this going the way you expected when you started?
- What has surprised you so far?
After completing:
- What would you do differently if you started this milestone over?
- What did you learn that you didn't expect to learn?

## Self-Assessment (complete after finishing)
- Design confidence (1-5): Could you make the major configuration decisions again without help?
- Implementation confidence (1-5): Could you reproduce this from scratch without notes?
- Transfer confidence (1-5): Could you apply the main pattern to a different but similar problem?

## My Notes
(Your free-form workspace)
```

---

### Prompt 6 -- P2 Milestones M1-M2 (2 entries)

> **Success:** 2 entries in Milestones for Project 2.

```
Add these 2 entries to the "Milestones" database. Set the Project relation to "Project 2: Under the Hood" for both. Do not rename any existing properties. Use the same section structure as the previous milestone entries.

---

ENTRY 1:
Title: "M1: Control Plane Configuration"
Milestone Number: M1
Status: Not Started
Tier Required: OSS + Free
Environment: Local
Cloud Required: unchecked
Optional: unchecked
Needs GitHub: unchecked
Lifecycle Thread: Infrastructure as Code
Previous Milestone: M3: Multi-Cluster Isolation

Page body:

## Goal
Create vClusters backed by different control plane stores. Compare operational behavior, startup time, resource consumption, and restart characteristics.

## Requirements
- One vCluster created with the default backing store (SQLite / embedded)
- One vCluster created with embedded etcd [Free]; confirm etcd pods are present in the host namespace
- Both clusters accept workloads; verify with a simple pod deployment to each
- Measure and record: pod count in each host namespace, approximate memory footprint of the control plane pod(s), time from creation to API server ready
- Restart the control plane pod for each vCluster (delete the pod, let it reschedule); verify workloads survive and the API server recovers

## Pressure You'll Feel
SQLite is simpler and starts faster. Etcd is the "production" choice. But production for what scale? What access pattern? The default exists because it fits most dev/test workloads. Before you default to etcd everywhere, what does your workload actually need from a backing store?

## Lifecycle Pressure
**Thread:** Infrastructure as Code
You created two clusters with different configurations. Are those configurations written down anywhere, or do you remember the flags you passed? If you delete both clusters right now and need to recreate them in an hour, what do you have to work from?

## Verification
- Pod listing for each vCluster namespace: SQLite shows 1 control plane pod; etcd variant shows additional etcd pod(s)
- After control plane pod restart: pod listing from inside the virtual cluster still returns previously deployed workloads

## Reference Links
(none for this milestone)

## Reflection Prompts
Before starting: What do you think will be the hardest part? What approach are you planning?
Mid-milestone: Is this going the way you expected? What has surprised you?
After completing: What would you do differently? What did you learn that you didn't expect?

## Self-Assessment (complete after finishing)
- Design confidence (1-5) | Implementation confidence (1-5) | Transfer confidence (1-5)

## My Notes
(Your free-form workspace)

---

ENTRY 2:
Title: "M2: Syncer Deep Dive"
Milestone Number: M2
Status: Not Started
Tier Required: OSS
Environment: Local
Cloud Required: unchecked
Optional: unchecked
Needs GitHub: unchecked
Lifecycle Thread: Testing
Previous Milestone: M1: Control Plane Configuration

Page body:

## Goal
Deploy a multi-tier application inside a vCluster. Trace how each tier's resources appear -- or don't appear -- on the host cluster. Probe the boundary of what the syncer manages.

## Requirements
- A three-tier application running inside the vCluster: frontend (Deployment + Service), backend (Deployment + Service), and a database (StatefulSet + PersistentVolumeClaim)
- Verified that Deployments exist in the virtual cluster but do NOT appear as Deployment objects on the host
- Verified that Pods synced to the host have rewritten names; document the naming pattern
- Verified that the PVC synced to the host and a PV was bound
- Manually add a label to a synced Pod directly on the host cluster; observe whether the label persists or is overwritten; explain why

## Pressure You'll Feel
The syncer rewrites names and only syncs certain resource types. When you try to debug a crashing pod, the name you see inside the vCluster doesn't match the name on the host. How do you trace the connection reliably? What's the pattern in the rewriting?

## Lifecycle Pressure
**Thread:** Testing
You deployed a three-tier app and checked it manually. If someone changes the syncer configuration tomorrow and PVCs stop syncing, how would you catch that before users do?

## Verification
Inside virtual context: `kubectl get deployments -n default` and `kubectl get pods -n default`.
On host context: `kubectl get deployments -n <vcluster-ns>` (should return nothing), `kubectl get pods -n <vcluster-ns>` (rewritten names), `kubectl get pvc -n <vcluster-ns>` (PVC should appear).

## Reference Links
vCluster Architecture Overview: https://www.vcluster.com/docs/vcluster/introduction/architecture/

## Reflection Prompts
Before starting: What do you think will be the hardest part? What approach are you planning?
Mid-milestone: Is this going the way you expected? What has surprised you?
After completing: What would you do differently? What did you learn that you didn't expect?

## Self-Assessment (complete after finishing)
- Design confidence (1-5) | Implementation confidence (1-5) | Transfer confidence (1-5)

## My Notes
(Your free-form workspace)
```

---

### Prompt 7 -- P2 Milestones M3-M4 (2 entries)

> **Success:** 2 more entries for Project 2.

```
Add these 2 entries to the "Milestones" database. Set the Project relation to "Project 2: Under the Hood". Do not rename any existing properties. Use the same section structure.

---

ENTRY 1:
Title: "M3: Networking"
Milestone Number: M3
Status: Not Started
Tier Required: OSS
Environment: Local
Cloud Required: unchecked
Optional: unchecked
Needs GitHub: unchecked
Lifecycle Thread: Version Control
Previous Milestone: M2: Syncer Deep Dive

Page body:

## Goal
Verify DNS resolution within a vCluster. Configure services that communicate across tiers. Set up ingress from outside the virtual cluster. Test the boundary of cross-vCluster service discovery.

## Requirements
- From inside a pod in the vCluster, resolve a service DNS name for another service in the same vCluster -- DNS must resolve
- Frontend service successfully calls backend service by DNS name (not IP)
- Ingress resource created inside the vCluster routes external traffic to the frontend; verify from outside the cluster
- Attempt to resolve a service from team-a inside team-b's DNS context; document the result
- Identify where DNS requests from inside the vCluster are ultimately resolved (trace the path)

## Pressure You'll Feel
Service names resolve differently depending on which cluster you're asking from. A service named `backend` in team-a and in team-b are two different things, but they share host node networking. Where does the DNS request actually go, and what prevents the wrong answer?

## Lifecycle Pressure
**Thread:** Version Control
Your DNS configuration, ingress resources, and inter-service wiring are accumulating. What's your system for tracking what you configured, and why?

**Thread:** Testing to CI bridge
You have a script that verifies your three-tier app is reachable. If you wanted that check to run automatically on every PR, what would need to change about how it's structured?

## Verification
From inside a pod in vCluster team-a: `nslookup backend.default.svc.cluster.local` should resolve to team-a's backend ClusterIP.
From inside a pod in vCluster team-b: same lookup should resolve to a different IP.

## Reference Links
(none for this milestone)

## Reflection Prompts
Before starting: What do you think will be the hardest part? What approach are you planning?
Mid-milestone: Is this going the way you expected? What has surprised you?
After completing: What would you do differently? What did you learn that you didn't expect?

## Self-Assessment (complete after finishing)
- Design confidence (1-5) | Implementation confidence (1-5) | Transfer confidence (1-5)

## My Notes
(Your free-form workspace)

---

ENTRY 2:
Title: "M4: Custom Resource Syncing"
Milestone Number: M4
Status: Not Started
Tier Required: Free
Environment: Local
Cloud Required: unchecked
Optional: unchecked
Needs GitHub: unchecked
Lifecycle Thread: Infrastructure as Code
Previous Milestone: M3: Networking

Page body:

## Goal
Define a Custom Resource Definition inside the vCluster. Configure sync rules so instances of that CRD appear on the host cluster. Verify bidirectional behavior and resource transformation via sync patches.

## Requirements
- A CRD defined inside the vCluster (you choose the schema; a simple resource is sufficient)
- A Custom Resource instance created inside the vCluster
- vcluster.yaml sync rules configured to sync this CRD to the host namespace
- The CR instance visible on the host cluster after the vCluster is updated with the new config
- A sync patch applied that transforms one field when the resource crosses the boundary; verify the transformation
- Verify behavior when the CRD does NOT exist on the host: what error surfaces and where?

## Pressure You'll Feel
Not everything syncs by default. When you add custom syncing, you're extending the contract between virtual and host. What breaks if the host doesn't have the CRD installed? Who is responsible for installing it?

## Lifecycle Pressure
**Thread:** Infrastructure as Code
Your sync configuration is now custom -- it lives in a vcluster.yaml. If you delete this vCluster and recreate it without that file, the sync rules vanish. Where does that file live?

## Verification
- The CR is visible on the host in the vCluster namespace
- The transformed field is present on the host-side resource
- Deleting the CR inside the vCluster removes it from the host

## Reference Links
vcluster.yaml Configuration: https://www.vcluster.com/docs/vcluster/configure/vcluster-yaml/

## Reflection Prompts
Before starting: What do you think will be the hardest part? What approach are you planning?
Mid-milestone: Is this going the way you expected? What has surprised you?
After completing: What would you do differently? What did you learn that you didn't expect?

## Self-Assessment (complete after finishing)
- Design confidence (1-5) | Implementation confidence (1-5) | Transfer confidence (1-5)

## My Notes
(Your free-form workspace)
```

---

### Prompt 8 -- P3 Milestones (3 entries)

> **Success:** 3 entries for Project 3.

```
Add these 3 entries to the "Milestones" database. Set the Project relation to "Project 3: Configuration & Access". Do not rename any existing properties. Use the same section structure.

---

ENTRY 1:
Title: "M1: vcluster.yaml Mastery"
Milestone Number: M1
Status: Not Started
Tier Required: OSS
Environment: Local
Cloud Required: unchecked
Optional: unchecked
Needs GitHub: unchecked
Lifecycle Thread: Version Control
Previous Milestone: M4: Custom Resource Syncing

Page body:

## Goal
Write a complete vcluster.yaml from scratch that configures sync rules, RBAC, resource limits, and scheduler behavior. Use it as the sole source of truth for cluster creation.

## Requirements
- A vcluster.yaml that produces a fully configured cluster without any additional flags
- Sync rules explicitly include at least one non-default resource type and exclude at least one default type
- Resource requests and limits set on the vCluster control plane pod
- RBAC configured so that a read-only ServiceAccount cannot create Deployments but can list Pods
- The vCluster deleted and recreated from the same vcluster.yaml -- behavior must be identical
- A kubeconfig produced that can be used by external tools (Lens, k9s)

## Pressure You'll Feel
Every option you explicitly set is a maintenance commitment. Every option you leave at default is an assumption about the future. What is the cost of a wrong default for your specific workload?

## Lifecycle Pressure
**Thread:** Version Control
This vcluster.yaml is your cluster's source of truth. What happens when two people need to change it? How do you know which version produced the running cluster?

## Verification
- Delete and recreate the cluster from the yaml only
- Verify read-only RBAC: creating a deployment as readonly ServiceAccount should fail with Forbidden
- Listing pods as readonly ServiceAccount should succeed

## Reference Links
(none for this milestone)

## Reflection Prompts
Before starting: What do you think will be the hardest part? What approach are you planning?
Mid-milestone: Is this going the way you expected? What has surprised you?
After completing: What would you do differently? What did you learn that you didn't expect?

## Self-Assessment (complete after finishing)
- Design confidence (1-5) | Implementation confidence (1-5) | Transfer confidence (1-5)

## My Notes
(Your free-form workspace)

---

ENTRY 2:
Title: "M2: Access Patterns"
Milestone Number: M2
Status: Not Started
Tier Required: OSS
Environment: Local to Cloud
Cloud Required: checked
Optional: unchecked
Needs GitHub: unchecked
Lifecycle Thread: Testing
Previous Milestone: M1: vcluster.yaml Mastery

Page body:

## Goal
Expose a vCluster through three distinct access methods. Understand the security and operational tradeoff of each.

## Requirements
- Method 1 (local): Access via port-forwarding; confirm cluster interaction works
- Method 2 (cloud): Access via Ingress with SSL passthrough; reachable at a hostname without port-forwarding
- Method 3 (cloud): Access via LoadBalancer service type; reachable at a stable external IP
- For each method, generate a kubeconfig -- three distinct files
- Generate a scoped kubeconfig with namespace-locked permissions
- Document the failure mode for each method

## Pressure You'll Feel
Port-forwarding works on your laptop but breaks in CI. Ingress requires an ingress controller and DNS. LoadBalancer requires cloud infrastructure. Each trades security for convenience differently. Which for a teammate? Which for a CI job?

## Lifecycle Pressure
**Thread:** Testing
Three access methods and three kubeconfigs. How do you verify all three still work after a config change? How do you verify the scoped kubeconfig can't escape its namespace?

## Verification
- For each kubeconfig, cluster interaction succeeds independently
- Scoped kubeconfig: access to allowed namespace succeeds, access to kube-system fails

## Reference Links
Design Principles: https://www.vcluster.com/docs/vcluster/introduction/design-principles

## Reflection Prompts
Before starting: What do you think will be the hardest part? What approach are you planning?
Mid-milestone: Is this going the way you expected? What has surprised you?
After completing: What would you do differently? What did you learn that you didn't expect?

## Self-Assessment (complete after finishing)
- Design confidence (1-5) | Implementation confidence (1-5) | Transfer confidence (1-5)

## My Notes
(Your free-form workspace)

---

ENTRY 3:
Title: "M3: Platform Governance"
Milestone Number: M3
Status: Not Started
Tier Required: Free
Environment: Local to Cloud
Cloud Required: checked
Optional: unchecked
Needs GitHub: unchecked
Lifecycle Thread: Infrastructure as Code
Previous Milestone: M2: Access Patterns

Page body:

## Goal
Use the vCluster Platform to enforce consistency across multiple virtual clusters using Projects and Templates.

## Requirements
- At least two Platform Projects created (e.g., backend-team, ml-team)
- A vCluster Template for each project with distinct resource limits, allowed namespaces, and node selectors
- A user granted admin to one project but no access to the other; verified isolation
- vClusters created from each template; verify template constraints are reflected
- Automatic snapshot configured; verify a snapshot is taken and visible

## Pressure You'll Feel
Templates enforce consistency -- but consistency for whom? A 4GB/2CPU template is reasonable for APIs but wrong for ML batch jobs with 32GB needs. When does a template help and when does it become a constraint people work around?

## Lifecycle Pressure
**Thread:** Infrastructure as Code
Your templates are infrastructure policy. They live in the Platform's database. If you rebuilt the Platform from scratch, could you? Where do templates live outside the UI?

## Verification
- Listing clusters in the wrong project as the restricted user should fail
- Resource quotas match the template definition
- Snapshot list shows at least one entry

## Reference Links
Platform Documentation: https://www.vcluster.com/docs/platform/

## Reflection Prompts
Before starting: What do you think will be the hardest part? What approach are you planning?
Mid-milestone: Is this going the way you expected? What has surprised you?
After completing: What would you do differently? What did you learn that you didn't expect?

## Self-Assessment (complete after finishing)
- Design confidence (1-5) | Implementation confidence (1-5) | Transfer confidence (1-5)

## My Notes
(Your free-form workspace)
```

---

### Prompt 9 -- P4 Milestones M1-M3 (3 entries)

> **Success:** 3 entries for Project 4.

```
Add these 3 entries to the "Milestones" database. Set the Project relation to "Project 4: Production Readiness". Do not rename any existing properties. Use the same section structure.

---

ENTRY 1:
Title: "M1: Deployment Topologies"
Milestone Number: M1
Status: Not Started
Tier Required: OSS + Free
Environment: Cloud
Cloud Required: checked
Optional: unchecked
Needs GitHub: unchecked
Lifecycle Thread: Infrastructure as Code
Previous Milestone: M3: Platform Governance

Page body:

## Goal
Deploy vClusters in three distinct node topologies. Measure the operational difference between shared and dedicated infrastructure.

## Requirements
- Topology 1 -- Shared nodes: vCluster pods on shared nodes alongside host workloads
- Topology 2 -- Dedicated node pool: vCluster pods exclusively on a tainted node pool
- Topology 3 -- Virtual nodes [Free]: workloads schedule without consuming real node capacity
- For each: record pod count, resource consumption, and blast radius of a runaway workload
- Simulate a blast radius test: deploy a pod requesting more memory than available

## Pressure You'll Feel
Shared nodes maximize density. Dedicated nodes maximize isolation. Virtual nodes sidestep the tradeoff at cost of abstraction. Your budget speaks to density; your SLA speaks to isolation. Which do you default to?

## Lifecycle Pressure
**Thread:** Infrastructure as Code
Three distinct topology configurations. How do you manage these as vCluster count grows from 3 to 30?

## Verification
For dedicated topology, verify all pods show dedicated node name(s) only.

## Reference Links
Deploy on AWS EKS: https://www.vcluster.com/docs/vcluster/deploy/control-plane/kubernetes-pod/environment/eks
Deploy on Google GKE: https://www.vcluster.com/docs/vcluster/deploy/control-plane/kubernetes-pod/environment/gke
Deploy on Azure AKS: https://www.vcluster.com/docs/vcluster/deploy/control-plane/kubernetes-pod/environment/aks

## Reflection Prompts
Before starting: What do you think will be the hardest part? What approach are you planning?
Mid-milestone: Is this going the way you expected? What has surprised you?
After completing: What would you do differently? What did you learn that you didn't expect?

## Self-Assessment (complete after finishing)
- Design confidence (1-5) | Implementation confidence (1-5) | Transfer confidence (1-5)

## My Notes
(Your free-form workspace)

---

ENTRY 2:
Title: "M2: Stateful Workloads"
Milestone Number: M2
Status: Not Started
Tier Required: OSS
Environment: Cloud
Cloud Required: checked
Optional: unchecked
Needs GitHub: unchecked
Lifecycle Thread: Testing
Previous Milestone: M1: Deployment Topologies

Page body:

## Goal
Run a production-representative stateful workload (PostgreSQL or Redis) inside a vCluster with persistent storage. Prove the data layer survives operational events.

## Requirements
- PostgreSQL (or Redis) deployed as a StatefulSet with a PVC
- Data written and verified queryable before disruption
- Data verified after: pod rescheduled, control plane restarted, node drained
- StorageClass mapping configured explicitly in vcluster.yaml
- Backup taken via Velero or platform snapshot; restore to new vCluster and verify data

## Pressure You'll Feel
Stateful workloads force you to understand PVC syncing, StorageClass mapping, and what happens when the host reschedules pods. The PVC exists in two places simultaneously. Which is authoritative?

## Lifecycle Pressure
**Thread:** Testing
Your database survived one rescheduling. How do you turn that into a repeatable guarantee?

## Verification
After each disruption event, query the database and confirm row count matches pre-disruption.

## Reference Links
(none for this milestone)

## Reflection Prompts
Before starting: What do you think will be the hardest part? What approach are you planning?
Mid-milestone: Is this going the way you expected? What has surprised you?
After completing: What would you do differently? What did you learn that you didn't expect?

## Self-Assessment (complete after finishing)
- Design confidence (1-5) | Implementation confidence (1-5) | Transfer confidence (1-5)

## My Notes
(Your free-form workspace)

---

ENTRY 3:
Title: "M3: Security Hardening"
Milestone Number: M3
Status: Not Started
Tier Required: OSS
Environment: Cloud
Cloud Required: checked
Optional: unchecked
Needs GitHub: unchecked
Lifecycle Thread: Testing
Previous Milestone: M2: Stateful Workloads

Page body:

## Goal
Harden a vCluster's host RBAC, enforce pod-level security standards, and validate that policies actually block what they claim to block.

## Requirements
- Syncer ServiceAccount restricted to minimum permissions; document what broke when you removed too much
- Pod Security Standards at `restricted` level; verify a privileged pod is rejected
- ResourceQuota and LimitRange applied; verify quota enforcement
- NetworkPolicy isolating vCluster pods from other host namespaces; verify traffic is blocked
- A policy violation attempted and confirmed rejected

## Pressure You'll Feel
The API server is isolated. The CNI and nodes are shared. Where is the actual security boundary? What do your API policies protect, and what do they leave open?

## Lifecycle Pressure
**Thread:** Testing
How do you prove policies still block after the next vCluster version upgrade?

## Verification
- Privileged pod must be rejected
- Over-quota deployment must be rejected
- Cross-namespace traffic must time out or be refused

## Reference Links
Annotations and Labels Reference: https://www.vcluster.com/docs/vcluster/reference/annotations

## Reflection Prompts
Before starting: What do you think will be the hardest part? What approach are you planning?
Mid-milestone: Is this going the way you expected? What has surprised you?
After completing: What would you do differently? What did you learn that you didn't expect?

## Self-Assessment (complete after finishing)
- Design confidence (1-5) | Implementation confidence (1-5) | Transfer confidence (1-5)

## My Notes
(Your free-form workspace)
```

---

### Prompt 10 -- P4 M4-M5 + P5 M1 (3 entries)

> **Success:** 3 more entries.

```
Add these 3 entries to the "Milestones" database. Do not rename any existing properties. Use the same section structure.

---

ENTRY 1 (Project 4: Production Readiness):
Title: "M4: Observability & Operations"
Milestone Number: M4
Status: Not Started
Tier Required: OSS + Free
Environment: Cloud
Cloud Required: checked
Optional: unchecked
Needs GitHub: unchecked
Lifecycle Thread: Version Control
Previous Milestone: M3: Security Hardening
Project: Project 4: Production Readiness

Page body:

## Goal
Make a vCluster production-observable: metrics, logs, high availability, and tested recovery.

## Requirements
- Prometheus scraping metrics from the control plane pod
- Log aggregation capturing workload and control plane logs in one view
- HA mode with leader election [Free]; verify leader election is active
- vCluster Pod killed manually; verify replacement comes up within your defined SLO
- Backup/restore cycle: backup, delete, restore, verify workloads return

## Pressure You'll Feel
The vCluster pod crashes at 2am. Do you know before your users do? Does your alerting fire on the right signal? Recovery is "API server responding and workloads healthy" -- not just "pod restarted."

## Lifecycle Pressure
**Thread:** Version Control
Your monitoring configs, alert rules, and backup schedules are operational infrastructure. Are they versioned?

## Verification
- Alert fires when vCluster pod is unhealthy
- Cluster interaction succeeds within SLO after pod replacement

## Reference Links
OSS vs Free Tier Comparison: https://www.vcluster.com/docs/vcluster/introduction/oss-vs-free

## Reflection Prompts
Before starting: What do you think will be the hardest part? What approach are you planning?
Mid-milestone: Is this going the way you expected? What has surprised you?
After completing: What would you do differently? What did you learn that you didn't expect?

## Self-Assessment (complete after finishing)
- Design confidence (1-5) | Implementation confidence (1-5) | Transfer confidence (1-5)

## My Notes
(Your free-form workspace)

---

ENTRY 2 (Project 4: Production Readiness):
Title: "M5: Lifecycle Management"
Milestone Number: M5
Status: Not Started
Tier Required: Enterprise
Environment: Cloud
Cloud Required: checked
Optional: checked
Needs GitHub: unchecked
Lifecycle Thread: Infrastructure as Code
Previous Milestone: M4: Observability & Operations
Project: Project 4: Production Readiness

Page body:

## Goal
Configure automatic sleep, wake, and deletion policies. Optimize cost at the platform level. (Optional -- requires Enterprise tier.)

## Requirements
- Sleep mode after 30 minutes of inactivity; verify the vCluster enters sleep
- Wake by kubectl command; measure wake latency
- CRON-based sleep schedule (nights and weekends); verify active
- Auto-delete for vClusters idle longer than 7 days; verify in platform config
- Cost comparison: active vs sleeping resource consumption

## Pressure You'll Feel
Every idle vCluster consumes resources. Sleep adds latency. Auto-delete destroys state. Where is the line between cost optimization and destroying someone's work?

## Lifecycle Pressure
**Thread:** Infrastructure as Code
Your lifecycle policies are platform-level configuration. If you rebuilt the platform, would they come back? How do you apply them consistently across teams?

## Verification
- Trigger sleep; pod count drops
- Interact with sleeping cluster; measure wake time
- Policy list shows auto-delete rule

## Reference Links
(none for this milestone)

## Reflection Prompts
Before starting: What do you think will be the hardest part? What approach are you planning?
Mid-milestone: Is this going the way you expected? What has surprised you?
After completing: What would you do differently? What did you learn that you didn't expect?

## Self-Assessment (complete after finishing)
- Design confidence (1-5) | Implementation confidence (1-5) | Transfer confidence (1-5)

## My Notes
(Your free-form workspace)

---

ENTRY 3 (Project 5: Ecosystem Integration):
Title: "M1: CI/CD Pipelines"
Milestone Number: M1
Status: Not Started
Tier Required: OSS
Environment: Cloud
Cloud Required: checked
Optional: unchecked
Needs GitHub: checked
Lifecycle Thread: Version Control, Infrastructure as Code, Testing
Previous Milestone: M5: Lifecycle Management
Project: Project 5: Ecosystem Integration

Page body:

## Goal
Build a GitHub Actions workflow that provisions an ephemeral vCluster per pull request, deploys the feature branch, runs smoke tests, and tears down on close.

## Requirements
- Workflow triggers on PR open and synchronize events
- Creates a uniquely named vCluster per PR
- Application deployed into the ephemeral cluster
- At least three smoke tests (HTTP check, readiness probe, functional assertion)
- Results posted as a GitHub PR status check
- On PR close/merge, workflow deletes the vCluster
- Workflow fails clearly if creation times out

## Pressure You'll Feel
Each open PR gets its own cluster. Cost scales with activity. What safeguards prevent runaway creation? What about stale PRs?

## Lifecycle Pressure
**Thread:** All three converge
Your CI pipeline creates infrastructure, deploys code, and runs tests -- all in one workflow file. That file is version-controlled, but the clusters are not. How do you audit what was created? How do you test the pipeline itself?

## Verification
- Open a draft PR; workflow creates a named vCluster
- Merge the PR; cleanup workflow deletes the cluster
- No PR-named cluster exists after cleanup

## Reference Links
GitHub Actions PR Environments: https://www.vcluster.com/docs/vcluster/integrations/github-actions/preview-environments

## Reflection Prompts
Before starting: What do you think will be the hardest part? What approach are you planning?
Mid-milestone: Is this going the way you expected? What has surprised you?
After completing: What would you do differently? What did you learn that you didn't expect?

## Self-Assessment (complete after finishing)
- Design confidence (1-5) | Implementation confidence (1-5) | Transfer confidence (1-5)

## My Notes
(Your free-form workspace)
```

---

### Prompt 11 -- P5 Milestones M2-M4 (3 entries)

> **Success:** 3 final milestone entries.

```
Add these 3 entries to the "Milestones" database. Set the Project relation to "Project 5: Ecosystem Integration". Do not rename any existing properties. Use the same section structure.

---

ENTRY 1:
Title: "M2: GitOps"
Milestone Number: M2
Status: Not Started
Tier Required: OSS
Environment: Cloud
Cloud Required: checked
Optional: unchecked
Needs GitHub: unchecked
Lifecycle Thread: Infrastructure as Code
Previous Milestone: M1: CI/CD Pipelines

Page body:

## Goal
Manage vCluster lifecycle declaratively using ArgoCD or Flux. The git repository is the source of truth.

## Requirements
- ArgoCD (or Flux) installed on the host cluster
- At least two vClusters defined as Helm releases in git; ArgoCD/Flux creates and reconciles them
- One vCluster registered as an ArgoCD Application target; workloads deployed from git
- An ApplicationSet or Kustomization generating per-environment vClusters from one template
- Drift test: manually delete a resource; confirm reconciliation
- Adding a new cluster definition to the repo creates a cluster without CLI commands

## Pressure You'll Feel
GitOps means git is the source of truth. But vClusters are often ephemeral. How do you reconcile "the repo defines everything" with "this cluster should exist only until the feature ships"?

## Lifecycle Pressure
**Thread:** Infrastructure as Code
Your entire platform is in git. What does the repo structure look like? How do you review a change that affects all environments?

## Verification
- Add a new manifest and push -- no CLI needed
- ArgoCD/Flux syncs; cluster appears and is accessible

## Reference Links
ArgoCD Integration: https://www.vcluster.com/docs/platform/integrations/argocd

## Reflection Prompts
Before starting: What do you think will be the hardest part? What approach are you planning?
Mid-milestone: Is this going the way you expected? What has surprised you?
After completing: What would you do differently? What did you learn that you didn't expect?

## Self-Assessment (complete after finishing)
- Design confidence (1-5) | Implementation confidence (1-5) | Transfer confidence (1-5)

## My Notes
(Your free-form workspace)

---

ENTRY 2:
Title: "M3: Multi-Tenancy Platform"
Milestone Number: M3
Status: Not Started
Tier Required: Free
Environment: Cloud
Cloud Required: checked
Optional: unchecked
Needs GitHub: unchecked
Lifecycle Thread: Testing
Previous Milestone: M2: GitOps

Page body:

## Goal
Design and operate a multi-team vCluster platform. You are now the platform team; other teams are your users.

## Requirements
- At least three tenant teams with Platform Projects, team-specific Templates, and provisioned vClusters
- Tenant admins can provision within their project but cannot modify another team's
- Capacity limits enforced per project namespace using ResourceQuotas; verify enforcement
- Template change does not affect already-running vClusters
- Platform-level change deployed to all tenant clusters; verify it reaches all

## Pressure You'll Feel
You're building the platform others use. Your users are your customers. They will work around constraints that feel too tight. What does "platform thinking" look like?

## Lifecycle Pressure
**Thread:** Testing
A change to shared infrastructure could affect all tenants. How do you test that one team's template change doesn't break another?

## Verification
- team-b admin cannot delete team-a's cluster
- Over-quota deployment fails
- Template update does not change running cluster config

## Reference Links
Platform API Reference: https://www.vcluster.com/docs/platform/api/

## Reflection Prompts
Before starting: What do you think will be the hardest part? What approach are you planning?
Mid-milestone: Is this going the way you expected? What has surprised you?
After completing: What would you do differently? What did you learn that you didn't expect?

## Self-Assessment (complete after finishing)
- Design confidence (1-5) | Implementation confidence (1-5) | Transfer confidence (1-5)

## My Notes
(Your free-form workspace)

---

ENTRY 3:
Title: "M4: Advanced Operations"
Milestone Number: M4
Status: Not Started
Tier Required: OSS + Free
Environment: Cloud
Cloud Required: checked
Optional: unchecked
Needs GitHub: unchecked
Lifecycle Thread: Version Control, Infrastructure as Code, Testing
Previous Milestone: M3: Multi-Tenancy Platform

Page body:

## Goal
Develop a vCluster plugin that extends syncer behavior. Optionally, explore one additional advanced operations scenario.

## Requirements
- A plugin that adds a custom annotation to every Pod synced to the host
- Plugin packaged as a container image and referenced in vcluster.yaml
- Plugin active in a running vCluster; verify annotation on host-synced pod
- Plugin survives vCluster restart
- Document one failure mode discovered during development

## Pressure You'll Feel
Each extension couples your platform to code you maintain. The question is not whether it works today -- it is whether you can detect when it silently breaks after upgrade.

## Lifecycle Pressure
**Thread:** All three converge
Your extension is a build artifact (IaC), a configuration (vcluster.yaml), and a test target. How do you manage all three?

## Verification
- Deploy a pod; verify custom annotation on host-synced pod
- Restart vCluster; verify annotation on new pods
- Document the failure mode

## Reference Links
(none for this milestone)

## Optional Extensions
Choose one if time permits: GPU Workload Isolation, Distro Migration (K3s vs K8s), or Cloud-Native Integrations (cert-manager, external-secrets, Istio).

## Reflection Prompts
Before starting: What do you think will be the hardest part? What approach are you planning?
Mid-milestone: Is this going the way you expected? What has surprised you?
After completing: What would you do differently? What did you learn that you didn't expect?

## Self-Assessment (complete after finishing)
- Design confidence (1-5) | Implementation confidence (1-5) | Transfer confidence (1-5)

## My Notes
(Your free-form workspace)
```

---

### Prompt 12 -- Resources Entries (13 entries)

> **Success:** 13 entries in Resources database with milestone relations.

```
Add these 13 entries to the "Resources" database. For each entry, set the "Related Milestones" relation to the milestone(s) listed. Do not rename any existing properties.

1. Title: "Architecture Overview"
   URL: https://www.vcluster.com/docs/vcluster/introduction/architecture/
   Related Milestones: M1: The Basic Lifecycle, M2: Syncer Deep Dive
   What to Look For: "Explains the syncer's design and why pod names get rewritten"

2. Title: "What Are Virtual Clusters"
   URL: https://www.vcluster.com/docs/vcluster/introduction/what-are-virtual-clusters
   Related Milestones: M2: Platform UI
   What to Look For: "The conceptual distinction vCluster solves -- read after creating clusters both ways"

3. Title: "vcluster.yaml Configuration"
   URL: https://www.vcluster.com/docs/vcluster/configure/vcluster-yaml/
   Related Milestones: M4: Custom Resource Syncing, M1: vcluster.yaml Mastery
   What to Look For: "Complete reference for everything configurable in vcluster.yaml"

4. Title: "Design Principles"
   URL: https://www.vcluster.com/docs/vcluster/introduction/design-principles
   Related Milestones: M2: Access Patterns
   What to Look For: "Why vCluster supports multiple access methods"

5. Title: "Platform Documentation"
   URL: https://www.vcluster.com/docs/platform/
   Related Milestones: M3: Platform Governance
   What to Look For: "Complete reference for Projects, Templates, and governance features"

6. Title: "Deploy on AWS EKS"
   URL: https://www.vcluster.com/docs/vcluster/deploy/control-plane/kubernetes-pod/environment/eks
   Related Milestones: M1: Deployment Topologies
   What to Look For: "Cloud-specific deployment considerations for EKS"

7. Title: "Deploy on Google GKE"
   URL: https://www.vcluster.com/docs/vcluster/deploy/control-plane/kubernetes-pod/environment/gke
   Related Milestones: M1: Deployment Topologies
   What to Look For: "Cloud-specific deployment considerations for GKE"

8. Title: "Deploy on Azure AKS"
   URL: https://www.vcluster.com/docs/vcluster/deploy/control-plane/kubernetes-pod/environment/aks
   Related Milestones: M1: Deployment Topologies
   What to Look For: "Cloud-specific deployment considerations for AKS"

9. Title: "Annotations and Labels Reference"
   URL: https://www.vcluster.com/docs/vcluster/reference/annotations
   Related Milestones: M3: Security Hardening
   What to Look For: "All vCluster annotations and labels that affect security behavior"

10. Title: "OSS vs Free Tier Comparison"
    URL: https://www.vcluster.com/docs/vcluster/introduction/oss-vs-free
    Related Milestones: M4: Observability & Operations
    What to Look For: "Where each tier boundary falls -- relevant for HA and leader election"

11. Title: "GitHub Actions PR Environments"
    URL: https://www.vcluster.com/docs/vcluster/integrations/github-actions/preview-environments
    Related Milestones: M1: CI/CD Pipelines
    What to Look For: "The integration pattern for ephemeral PR environments"

12. Title: "ArgoCD Integration"
    URL: https://www.vcluster.com/docs/platform/integrations/argocd
    Related Milestones: M2: GitOps
    What to Look For: "How ArgoCD integrates with vCluster Platform"

13. Title: "Platform API Reference"
    URL: https://www.vcluster.com/docs/platform/api/
    Related Milestones: M3: Multi-Tenancy Platform
    What to Look For: "API reference for the multi-tenant platform resources"
```

---

### Checkpoint 2

```
Count the entries in each database:
- Milestones should have exactly 19 entries
- Projects should have exactly 5 entries
- Resources should have exactly 13 entries

List any missing entries by name. Also verify that every milestone has its "Project" relation set and its "Previous Milestone" self-relation set (except M1: The Basic Lifecycle, which has no previous milestone).
```

---

## Phase 3: Standalone Pages

### Prompt 13 -- Home Page

> **Success:** A page titled "Home" with curriculum introduction content.

```
Create a page called "Home" inside the "vCluster Learning Curriculum" page. Add this content:

# How to Use This Curriculum

**Problem-first philosophy.** Milestones describe what your system must do, not how to build it. Read the full milestone chain for a project before starting any single milestone -- later milestones often invalidate the naive approach from earlier ones.

**"Pressure you'll feel"** sections are the pedagogical core. They name the concept you are meant to struggle with. Sit with the friction before looking for answers.

**"Lifecycle pressure"** blocks surface version control, Infrastructure as Code, and testing questions at the moment they become real -- not before.

# How to Navigate

- The Roadmap page provides a visual overview of all projects and milestones
- The Milestones database is where you do your work -- one entry per milestone
- The Projects database shows your overall progress per project
- The Resources database collects all external documentation links
- The Glossary page defines key vCluster terms
- Use the Progress Dashboard views to see where you are at a glance

# Tier System

| Tag | Meaning |
|-----|---------|
| OSS | vCluster open-source CLI only (no platform account needed) |
| Free | vCluster Platform free tier (loft.sh account required) |
| Optional -- Enterprise | Enterprise features; optional bonus content |

# Tooling Paths

The curriculum does not fork -- all learners work through the same milestones. Only the workflow differs.

**Path 1: Notion Only**
You work entirely from Notion. Progress is tracked in the Milestones database. Reflection prompts are built into each milestone page.

**Path 2: Notion + Git + Claude Code**
You also clone the curriculum repository and use Claude Code as an AI mentor. Claude Code provides Socratic questioning, automated progress tracking, and commit workflows. See git_claude_workflow_guide.md in the repository for setup.

Both paths use this same Notion workspace. Git + Claude Code is a layer on top, not a replacement. You can add it at any time.
```

---

### Prompt 14 -- Roadmap Page

> **Success:** A page with the curriculum flow table, Mermaid diagram, and lifecycle threads.

```
Create a page called "Roadmap" inside the "vCluster Learning Curriculum" page. Add this content:

# Curriculum Flow

| Order | Project | Focus | Environment | Tiers |
|-------|---------|-------|-------------|-------|
| 1 | First Contact | Basic lifecycle, UI, isolation | Local | OSS + Free |
| 2 | Under the Hood | Control plane, syncer, networking, CRDs | Local | OSS + Free |
| 3 | Configuration & Access | vcluster.yaml, access patterns, governance | Local to Cloud | OSS + Free |
| 4 | Production Readiness | Topologies, stateful, security, HA, lifecycle | Cloud | OSS + Free + Enterprise |
| 5 | Ecosystem Integration | CI/CD, GitOps, multi-tenancy, extensions | Cloud | OSS + Free |

Each project builds on the last. Milestones within a project must be completed in order.

# Overview Diagram

Add this as a code block with language set to "mermaid":

flowchart TD
    P1["Project 1: First Contact\nlocal | OSS + Free\nA cluster inside a cluster"]
    P2["Project 2: Under the Hood\nlocal | OSS + Free\nSyncer, control plane, networking, CRDs"]
    P3["Project 3: Configuration & Access\nlocal to cloud | OSS + Free\nvcluster.yaml, access methods, governance"]
    P4["Project 4: Production Readiness\ncloud | OSS + Free + Enterprise\nTopologies, stateful, security, HA, lifecycle"]
    P5["Project 5: Ecosystem Integration\ncloud | OSS + Free\nCI/CD, GitOps, multi-tenancy, platform building"]
    P1 --> P2 --> P3 --> P4 --> P5

# Lifecycle Threads

These three threads run parallel to the milestones:

| Thread | What It Teaches | Where It Appears |
|--------|----------------|-----------------|
| Version Control | Tracking what you configured, why, and how to reproduce it | P1-M1, P2-M3, P3-M1, P4-M4, P5-M2 |
| Infrastructure as Code | Moving from manual steps to declarative definitions | P1-M2, P2-M1, P2-M4, P3-M3, P4-M1, P4-M5 |
| Testing / Validation | Proving your system works repeatably, not just once | P1-M3, P2-M2, P3-M2, P4-M2, P4-M3, P5-M3 |
```

---

### Prompt 15 -- Glossary Page

> **Success:** A page with 12 term definitions.

```
Create a page called "Glossary" inside the "vCluster Learning Curriculum" page. Add this content as a table:

| Term | Definition |
|------|-----------|
| vCluster | A virtual Kubernetes cluster that runs as pods inside a host cluster's namespace. Has its own API server and control plane but shares the host's compute and networking. |
| Host cluster | The real Kubernetes cluster where vCluster pods run. Also called the "physical" or "underlying" cluster. |
| Virtual cluster | The Kubernetes API exposed by the vCluster. Workloads see an isolated cluster, but pods run on the host. |
| Syncer | The component that copies resources between virtual and host clusters. Rewrites names, labels, and namespaces as resources cross the boundary. |
| Name rewriting | The syncer renames resources when syncing to the host to prevent collisions. A pod named nginx in virtual cluster dev becomes something like nginx-x-default-x-dev on the host. |
| Backing store | The data store for the virtual API server state. Options: embedded SQLite (lightweight, default) and embedded etcd (more production-like). |
| Control plane | The API server (and optionally etcd) pod(s) that make up the vCluster's Kubernetes control plane. Runs as a regular workload in the host namespace. |
| vcluster.yaml | The configuration file defining sync rules, resource limits, RBAC settings, and other behavior. Source of truth for cluster configuration. |
| Template | A vCluster Platform concept. A reusable cluster definition with enforced constraints. Used to provision consistent clusters across teams. |
| Project | A vCluster Platform concept. An isolation boundary grouping vClusters with shared access controls. |
| Topology | How vCluster pods are placed on host nodes: shared, dedicated (own node pool), or virtual (virtual nodes). |
| Sleep mode | An Enterprise feature that scales a vCluster's control plane to zero after inactivity. Wakes on the next API request. |
```

---

## Phase 4: Views

### Prompt 16 -- Milestones Database Views

> **Success:** 6 views on the Milestones database.

```
Create these views on the "Milestones" database. Do not modify any existing properties or entries.

1. View name: "Board"
   Type: Board view
   Group by: Project
   Sort by: Milestone Number ascending

2. View name: "Current Focus"
   Type: Table view
   Filter: Status = "In Progress"
   Visible columns: Title, Project, Milestone Number, Lifecycle Thread

3. View name: "Up Next"
   Type: Table view
   Filter: Status = "Not Started"
   Sort: Milestone Number ascending
   Visible columns: Title, Project, Milestone Number, Tier Required, Environment

4. View name: "Completed"
   Type: Table view
   Filter: Status = "Complete"
   Sort: Date Completed descending
   Visible columns: Title, Project, Date Completed, Design Confidence, Implementation Confidence, Transfer Confidence

5. View name: "By Lifecycle Thread"
   Type: Table view
   Group by: Lifecycle Thread
   Visible columns: Title, Project, Milestone Number, Status

6. View name: "Feasibility"
   Type: Table view
   Visible columns: Title, Tier Required, Environment, Cloud Required, Optional, Needs GitHub, Status
```

---

## Phase 5: Manual Finishing Touches

These cannot be created by Notion AI and must be done manually:

- [ ] **Database template:** On the Milestones database, create a template with the standard page body structure (Goal, Requirements, Pressure You'll Feel, Lifecycle Pressure, Verification, Reference Links, Reflection Prompts, Self-Assessment, My Notes)
- [ ] **Completion rollup:** On the Projects database, add a Rollup property that calculates percent of related milestones with Status = Complete
- [ ] **Verify Previous Milestone relations:** Check that each milestone's self-relation points to the correct predecessor
- [ ] **Verify Resource relations:** Check that each Resource entry links to the correct milestones
- [ ] **Optional -- Buttons:** Add buttons for "Mark in progress" and "Mark complete" on milestone pages
- [ ] **Optional -- Synced blocks:** Create synced blocks for the reflection prompt rubric and tier system table

---

## Repair Prompt

If anything is missing after running all prompts, use this:

```
Audit all databases in this workspace against this specification:

- Projects database: 5 entries, properties: Title, Focus (rich text), Environment (select), Tiers (multi-select)
- Milestones database: 19 entries, properties: Title, Project (relation), Milestone Number (select), Status (status), Tier Required (select), Environment (select), Cloud Required (checkbox), Optional (checkbox), Needs GitHub (checkbox), Previous Milestone (self-relation), Lifecycle Thread (multi-select), Date Completed (date), Design Confidence (number), Implementation Confidence (number), Transfer Confidence (number)
- Resources database: 13 entries, properties: Title, URL (url), Related Milestones (relation), What to Look For (rich text)

Identify any missing properties, entries, relations, or views. Fix only the gaps -- do not modify anything that already matches this specification.
```
