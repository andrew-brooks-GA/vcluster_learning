# vCluster Learning Path

A hands-on, milestone-based curriculum for mastering vCluster — from first install to
production-grade platform engineering. Each project builds on the last. Milestones within
a project must be completed in order; projects can overlap once prerequisites are met.

---

## How to Use This Curriculum

**Problem-first philosophy.** Milestones describe what your system must *do*, not how to
build it. Read the full milestone chain for a project before starting any single milestone —
later milestones often invalidate the naive approach from earlier ones.

**Pressure you'll feel** sections are the pedagogical core. They name the concept you are
meant to struggle with. Sit with the friction before looking for answers.

**Lifecycle pressure** blocks surface version control, IaC, and testing questions at the
moment they become real — not before. They ask questions; they do not issue commands.

---

## Tier System

| Tag | Meaning |
|-----|---------|
| `[OSS]` | vCluster open-source CLI only (`vcluster` binary, no platform) |
| `[Free]` | vCluster Platform free tier (loft.sh account required) |
| `[Optional — Enterprise]` | vCluster Platform enterprise features (trial or licensed); milestones with this tag are optional bonus content |

Free tier is the curriculum ceiling. Milestones marked `[OSS]` work without a Platform
account. One optional milestone (P4-M5) requires Enterprise features.

---

## Environment Requirements

| Tag | What you need |
|-----|---------------|
| `[local]` | kind, k3d, or minikube; kubectl; vcluster CLI |
| `[cloud]` | A real Kubernetes cluster (EKS, GKE, AKS, or equivalent) |
| `[local → cloud]` | Starts locally; a later step requires a cloud cluster |

**Assumed prerequisites (not taught here):**
- kubectl installed and basic familiarity with pods, deployments, services, namespaces
- Helm v3 installed
- Docker or compatible container runtime
- A GitHub account (required for Project 5 CI/CD milestone)

---

## Curriculum Overview

| Project | Focus | Environment | Tiers |
|---------|-------|-------------|-------|
| 1 — First Contact | Basic lifecycle, UI, isolation | local | OSS + Free |
| 2 — Under the Hood | Control plane, syncer, networking, CRDs | local | OSS + Free |
| 3 — Configuration & Access | vcluster.yaml, access patterns, governance | local → cloud | OSS + Free |
| 4 — Production Readiness | Topologies, stateful, security, HA, lifecycle | cloud | OSS + Free (+ optional Enterprise) |
| 5 — Ecosystem Integration | CI/CD, GitOps, multi-tenancy, extensions | cloud | OSS + Free |

---

---

# Project 1: First Contact `[local]` `[OSS + Free]`

**Goal:** Establish the mental model. A vCluster is a full Kubernetes API server running
as a workload inside a host namespace. Every subsequent project builds on this model.

**Covers:** Installation, basic lifecycle, platform UI, isolation between co-located clusters.

---

## M1: The Basic Lifecycle `[OSS]` `[local]`

Install the vCluster CLI. Create a vCluster, connect to it, deploy a workload, observe
how it appears on the host, and perform a clean deletion.

**Requirements**

- vCluster CLI installed and `vcluster version` returns a version string
- A vCluster named `dev` created in a host namespace of your choice
- nginx Deployment running inside the virtual cluster (verified with `kubectl get pods` against the virtual context)
- The same Pod visible on the host cluster with a rewritten name (the vCluster syncer appends a suffix); names must not match between virtual and host
- `kubectl config get-contexts` shows both the host context and the vCluster context as distinct entries
- `vcluster delete dev` completes cleanly; the host namespace is absent afterward

**Pressure you'll feel**

You're running a cluster inside a cluster. When you type `kubectl`, which cluster are you
talking to? The host and virtual contexts both look like normal Kubernetes clusters.
A misrouted command in the wrong context is hard to notice and easy to make. What's
your strategy for always knowing where your commands land?

**Verification**

```
# Inside virtual context
kubectl get pods -n default

# Switch to host context
kubectl config use-context <host>
kubectl get pods -n <vcluster-namespace>
# The pod names here should contain the vCluster suffix — not the names you set
```

**Reference:** [Architecture Overview](https://www.vcluster.com/docs/vcluster/introduction/architecture/) — You just saw the syncer rewriting pod names. This document explains the design principles behind that behavior.

**Lifecycle pressure: Version control**

You just typed a sequence of CLI commands to create, connect, and populate a cluster.
If you closed this terminal right now, what would you need to remember to reproduce
this exact environment tomorrow? Is there anything you could write down — or check in —
that would make recreation mechanical rather than memorized?

---

## M2: Platform UI `[Free]` `[local]`

Install the vCluster Platform and create a vCluster through the web UI. Compare what
the UI creates with what the CLI created in M1.

**Requirements**

- vCluster Platform running locally (via `vcluster platform start` or Helm install)
- Platform UI accessible in a browser; login works
- A vCluster created through the UI — not the CLI
- The UI-created vCluster is functional: you can deploy a pod to it via kubectl
- Both the M1 CLI vCluster and the M2 UI vCluster are visible and distinguishable in the platform UI
- You can identify at least one configuration difference between what the UI defaults produced vs the CLI defaults from M1

**Pressure you'll feel**

The CLI and UI both create vClusters. For this milestone they produce the same result.
But when does one make more sense than the other? Think about who the operator is,
what their Kubernetes familiarity is, and whether the operation will happen once or a
hundred times.

**Verification**

- Navigate to the platform UI and confirm both clusters are listed
- Click into the UI-created cluster; download its kubeconfig from the UI
- Use that kubeconfig to run `kubectl get nodes` — one node should be returned

**Reference:** [What Are Virtual Clusters](https://www.vcluster.com/docs/vcluster/introduction/what-are-virtual-clusters) — You've now created vClusters both ways. This explains the conceptual distinction this architecture is solving.

**Lifecycle pressure: Infrastructure as Code**

You clicked through a UI to create a cluster. Could your teammate reproduce that cluster
from your description? Is there a way to capture what you configured — or is the cluster
definition living only in the platform's database?

---

## M3: Multi-Cluster Isolation `[OSS]` `[local]`

Run two or more vClusters simultaneously on the same host. Deploy different workloads
to each. Verify that resources in one cluster are invisible from the other.

**Requirements**

- At least two vClusters running simultaneously: `team-a` and `team-b`
- Each vCluster has a distinct Deployment with a distinct image (e.g., nginx vs httpd)
- From within `team-a`'s context, `kubectl get pods --all-namespaces` returns no pods belonging to `team-b`'s workloads (and vice versa)
- Both vClusters are visible as separate namespaces on the host cluster
- A `kubectl get namespaces` inside either virtual cluster shows only the default set — not the host's full namespace list

**Pressure you'll feel**

Both clusters share the same host nodes, the same CNI, and the same etcd (or SQLite).
What exactly separates them? If the isolation is at the API server level, what reaches
through that layer? What can a workload inside one vCluster observe about the other —
directly or indirectly?

**Verification**

```
# Switch to team-a context
kubectl get pods --all-namespaces
# team-b workloads must not appear

# Switch to team-b context
kubectl get pods --all-namespaces
# team-a workloads must not appear

# Switch to host context
kubectl get namespaces
# Both vcluster namespaces should be present
```

**Lifecycle pressure: Testing**

You verified isolation by checking manually — once. How do you prove it every time a
config change is made? If someone changes the sync configuration tomorrow, what would
break your manual check, and how would you know it broke?

---

---

# Project 2: Under the Hood `[local]` `[OSS + Free]`

**Goal:** Understand the mechanics. The vCluster syncer is the engine. Understanding what
it syncs, what it rewrites, and what it leaves alone is the prerequisite for every
advanced configuration in Projects 3–5.

**Covers:** Control plane variants, syncer behavior, DNS and networking, custom resource syncing.

---

## M1: Control Plane Configuration `[OSS + Free]` `[local]`

Create vClusters backed by different control plane stores. Compare operational behavior,
startup time, resource consumption, and restart characteristics.

**Requirements**

- One vCluster created with the default backing store (SQLite / embedded)
- One vCluster created with embedded etcd `[Free]`; confirm etcd pods are present in the host namespace
- Both clusters accept workloads; verify with a simple pod deployment to each
- Measure and record: pod count in each host namespace, approximate memory footprint of the control plane pod(s), time from `vcluster create` to API server ready
- Restart the control plane pod for each vCluster (delete the pod, let it reschedule); verify workloads survive and the API server recovers

**Pressure you'll feel**

SQLite is simpler and starts faster. Etcd is the "production" choice. But production for
what scale? What access pattern? The default exists because it fits most dev/test
workloads. Before you default to etcd everywhere, what does your workload actually need
from a backing store?

**Verification**

- `kubectl get pods -n <vcluster-namespace>` for each: SQLite shows 1 control plane pod; etcd variant shows additional etcd pod(s) `[Free]`
- After control plane pod restart: `kubectl get pods` from inside the virtual cluster still returns previously deployed workloads

**Lifecycle pressure: Infrastructure as Code**

You created two clusters with different configurations. Are those configurations written
down anywhere, or do you remember the flags you passed? If you delete both clusters
right now and need to recreate them in an hour, what do you have to work from?

---

## M2: Syncer Deep Dive `[OSS]` `[local]`

Deploy a multi-tier application inside a vCluster. Trace how each tier's resources appear
— or don't appear — on the host cluster. Probe the boundary of what the syncer manages.

**Requirements**

- A three-tier application running inside the vCluster: frontend (Deployment + Service), backend (Deployment + Service), and a database (StatefulSet + PersistentVolumeClaim)
- Verified that Deployments exist in the virtual cluster but do NOT appear as Deployment objects on the host
- Verified that Pods synced to the host have rewritten names; document the naming pattern (what is appended, what is preserved)
- Verified that the PVC synced to the host and a PV was bound
- Manually add a label to a synced Pod directly on the host cluster; observe whether the label persists or is overwritten; explain why

**Pressure you'll feel**

The syncer rewrites names and only syncs certain resource types. When you try to debug
a crashing pod, the name you see inside the vCluster doesn't match the name on the
host. You need to find the host pod to get to node-level logs. How do you trace the
connection reliably? What's the pattern in the rewriting?

**Verification**

```
# Inside virtual context
kubectl get deployments -n default   # should show your three deployments
kubectl get pods -n default          # note the pod names

# On host context
kubectl get deployments -n <vcluster-ns>   # should return nothing (or only vcluster internals)
kubectl get pods -n <vcluster-ns>          # should show pods with rewritten names
kubectl get pvc -n <vcluster-ns>           # PVC should appear here
```

**Reference:** [vCluster Architecture Overview](https://www.vcluster.com/docs/vcluster/introduction/architecture/) — You just traced the syncer boundary by observation. This describes the design intent behind what you found.

**Lifecycle pressure: Testing**

You deployed a three-tier app and checked it manually. If someone changes the syncer
configuration tomorrow and PVCs stop syncing, how would you catch that before users
do? What would a minimal automated check look like for "all three tiers are up and
reachable"?

---

## M3: Networking `[OSS]` `[local]`

Verify DNS resolution within a vCluster. Configure services that communicate across
tiers. Set up ingress from outside the virtual cluster. Test the boundary of
cross-vCluster service discovery.

**Requirements**

- From inside a pod in the vCluster, resolve `<service>.<namespace>.svc.cluster.local` for another service in the same vCluster — DNS must resolve
- Frontend service successfully calls backend service by DNS name (not IP); demonstrate with a curl from frontend pod to backend service hostname
- Ingress resource created inside the vCluster routes external traffic to the frontend; verify from outside the cluster
- Attempt to resolve a service from `team-a` inside `team-b`'s DNS context; document the result and explain it
- Identify where DNS requests from inside the vCluster are ultimately resolved (trace the path: virtual CoreDNS → syncer → host CoreDNS, or alternative)

**Pressure you'll feel**

Service names resolve differently depending on which cluster you're asking from. A
service named `backend` in vCluster `team-a` and a service named `backend` in vCluster
`team-b` are two different things, but they share host node networking. Where does the
DNS request actually go, and what prevents the wrong answer from coming back?

**Verification**

```
# From inside a pod in vCluster team-a
nslookup backend.default.svc.cluster.local
# Should resolve to team-a's backend ClusterIP

# From inside a pod in vCluster team-b  
nslookup backend.default.svc.cluster.local
# Should resolve to team-b's backend ClusterIP — a different IP
```

**Lifecycle pressure: Version control**

Your DNS configuration, ingress resources, and inter-service wiring are accumulating.
You'll need to recreate this setup in Project 3. What's your system for tracking what
you configured, and why you configured it that way?

**Lifecycle pressure: Testing → CI bridge**

You have a script that verifies your three-tier app is reachable and its services respond. If you wanted that check to run automatically every time someone opens a pull request, what would need to change about how the script is structured? What's the difference between a script you run manually and one a CI system can run without your presence?

---

## M4: Custom Resource Syncing `[Free]` `[local]`

Define a Custom Resource Definition inside the vCluster. Configure sync rules so instances
of that CRD appear on the host cluster. Verify bidirectional behavior and resource
transformation via sync patches.

**Requirements**

- A CRD defined inside the vCluster (you choose the schema; a simple `Widget` or `Config` resource is sufficient)
- A Custom Resource instance created inside the vCluster
- `vcluster.yaml` sync rules configured to sync this CRD to the host namespace
- The CR instance visible on the host cluster after the vCluster is updated with the new config
- A sync patch applied that transforms one field (e.g., adds a label or rewrites an annotation) when the resource crosses the boundary; verify the transformation happened
- Verify behavior when the CRD does NOT exist on the host: what error surfaces and where?

**Pressure you'll feel**

Not everything syncs by default. When you add custom syncing, you're extending the
contract between virtual and host. The host cluster operator may not know or care about
your CRD. What breaks if the host doesn't have the CRD installed? Who is responsible
for installing it? What does that mean for the "self-service" promise of vCluster?

**Verification**

- `kubectl get widgets -n <vcluster-ns>` on the host returns your CR instance
- The transformed field (label/annotation) is present on the host-side resource
- Deleting the CR inside the vCluster removes it from the host; confirm both directions

**Reference:** [vcluster.yaml Configuration](https://www.vcluster.com/docs/vcluster/configure/vcluster-yaml/) — You just configured sync rules in vcluster.yaml. This is the complete reference for what can be configured there.

**Lifecycle pressure: Infrastructure as Code**

Your sync configuration is now custom — it lives in a `vcluster.yaml`. If you delete this
vCluster and recreate it without that file, the sync rules vanish. Where does that file
live? Is it checked in anywhere? Is it the same file you started editing in M1?

---

---

# Project 3: Configuration & Access `[local → cloud]` `[OSS + Free]`

**Goal:** Move from "it runs" to "it's configured intentionally." A production vCluster
has explicit RBAC, resource limits, sync rules, and documented access patterns.

**Covers:** vcluster.yaml authoring, access methods, platform governance and templates.

---

## M1: vcluster.yaml Mastery `[OSS]` `[local]`

Write a complete `vcluster.yaml` from scratch that configures sync rules, RBAC, resource
limits, and scheduler behavior. Use it as the sole source of truth for cluster creation.

**Requirements**

- A `vcluster.yaml` that, when passed to `vcluster create --values`, produces a fully configured cluster without any additional flags
- Sync rules explicitly include at least one non-default resource type and exclude at least one default type
- Resource requests and limits set on the vCluster control plane pod
- RBAC configured so that a "read-only" ServiceAccount inside the virtual cluster cannot create Deployments but can list Pods
- The vCluster deleted and recreated from the same `vcluster.yaml` — behavior must be identical on second creation
- `vcluster platform kubeconfig <name> --project <project>` produces a kubeconfig that can be used by external tools (Lens, k9s)

**Pressure you'll feel**

Every option you explicitly set is a maintenance commitment. Every option you leave at default is an assumption about the future. The real question is not what to configure — it is what the cost of a wrong default is for your specific workload. Pick one option you set explicitly and ask: what breaks if this default changes in a future vCluster version? Pick one you left at default and ask: what would make that default wrong for your use case?

**Verification**

```
# Delete existing cluster
vcluster delete <name>

# Recreate from yaml only
vcluster create <name> --values vcluster.yaml

# Verify read-only RBAC
kubectl --as system:serviceaccount:default:readonly create deployment test --image=nginx
# Should fail with Forbidden

kubectl --as system:serviceaccount:default:readonly get pods
# Should succeed
```

**Lifecycle pressure: Version control**

This `vcluster.yaml` is your cluster's source of truth. What happens when two people
need to change it? How do you know which version produced the cluster that's running
right now? How do you review a proposed change before it's applied?

---

## M2: Access Patterns `[OSS]` `[local → cloud]`

Expose a vCluster through three distinct access methods. Understand the security and
operational tradeoff of each.

**Requirements**

- **Method 1 (local):** Access via `vcluster connect` port-forwarding; confirm `kubectl get nodes` works through the tunnel
- **Method 2 (cloud):** Access via Ingress with SSL passthrough; the vCluster API server must be reachable at a hostname without port-forwarding active
- **Method 3 (cloud):** Access via LoadBalancer service type; the API server reachable at a stable external IP
- For each method, generate a kubeconfig that encodes that access method — three distinct kubeconfig files
- Generate a scoped kubeconfig with namespace-locked permissions (cannot access resources outside one namespace)
- Document the failure mode for each method: what breaks first if the connection mechanism fails?

**Pressure you'll feel**

Port-forwarding works perfectly on your laptop. It breaks silently in a CI pipeline
when the port-forward process dies. Ingress requires your cluster to have an ingress
controller and a valid DNS record. LoadBalancer requires cloud infrastructure. Each
method trades security for convenience and operational simplicity in a different way.
Which one would you give to a teammate? Which would you give to a CI job?

**Verification**

- For each kubeconfig, confirm `kubectl --kubeconfig <file> get nodes` succeeds independently (no active port-forward for methods 2 and 3)
- For the scoped kubeconfig, confirm `kubectl --kubeconfig scoped.yaml get pods -n allowed-namespace` succeeds and `kubectl --kubeconfig scoped.yaml get pods -n kube-system` fails

**Reference:** [Design Principles](https://www.vcluster.com/docs/vcluster/introduction/design-principles) — You just implemented three access patterns with different security tradeoffs. This explains the design thinking behind why vCluster supports multiple access methods.

**Lifecycle pressure: Testing**

You have three access methods and three kubeconfigs. How do you verify all three are
still working after a config change? How do you verify the scoped kubeconfig actually
can't escape its namespace? Is that a test you run once or every time something changes?

---

## M3: Platform Governance `[Free]` `[local → cloud]`

Use the vCluster Platform to enforce consistency across multiple virtual clusters.
The Platform organizes clusters into **Projects** (isolation boundaries with access
controls) and creates them from **Templates** (reusable cluster definitions with
enforced constraints). This milestone teaches both concepts through hands-on use.

**Requirements**

- At least two Platform Projects created (e.g., `backend-team`, `ml-team`)
- A vCluster Template created for each project with distinct resource limits, allowed namespaces, and node selectors
- A user (or ServiceAccount) granted admin access to `backend-team` but no access to `ml-team`; verified that the user cannot list clusters in the other project
- vClusters created from each template; verify template-enforced constraints are reflected in the actual cluster configuration
- Automatic snapshot configured on at least one vCluster; verify a snapshot is taken and is visible in the UI or API

**Pressure you'll feel**

Templates enforce consistency — but consistency for whom? A template that gives every
cluster 4GB RAM and 2 CPUs is reasonable for a backend team running APIs. It might be
completely wrong for an ML team that runs batch jobs with 32GB memory requirements.
When does a template help and when does it become a constraint that people work around?
How do you design a template that's opinionated enough to be useful but flexible enough
to be actually used?

**Verification**

- `vcluster platform list vclusters --project ml-team` as the backend-team user should fail or return nothing
- `kubectl describe namespace default` inside a template-created vCluster shows resource quotas matching the template definition
- Snapshot list shows at least one entry for the configured vCluster

**Reference:** [Platform Documentation](https://www.vcluster.com/docs/platform/) — You just used Projects, Templates, and access management. This is the complete reference for platform governance features.

**Lifecycle pressure: Infrastructure as Code**

Your templates are infrastructure policy. They live in the Platform's database right now.
If you needed to recreate the Platform from scratch, could you? Where do your templates
live outside the UI? How would you propose a change to a template for review?

---

---

# Project 4: Production Readiness `[cloud required]` `[OSS + Free + Enterprise]`

**Goal:** Close the gap between "works on my laptop" and "my team depends on this."
Production means observable, recoverable, and hardened — not just functional.

**Covers:** Deployment topologies, stateful workloads, security hardening, HA and observability, lifecycle policies.

---

## M1: Deployment Topologies `[OSS → Free]` `[cloud]`

Deploy vClusters in three distinct node topologies. Measure the operational difference
between shared infrastructure and dedicated infrastructure.

**Requirements**

- **Topology 1 — Shared nodes:** vCluster pods scheduled on shared nodes alongside host workloads
- **Topology 2 — Dedicated node pool:** vCluster pods (control plane + workloads) scheduled exclusively on a tainted node pool using tolerations and node selectors in `vcluster.yaml`
- **Topology 3 — Virtual nodes `[Free]`:** vCluster using virtual node provider; workloads schedule without consuming real node capacity
- For each topology: record the pod count on the host, approximate node resource consumption, and how a runaway workload inside the vCluster affects host neighbors
- Simulate a blast radius test: deploy a pod requesting more memory than a shared node can provide; observe what it does to each topology

**Pressure you'll feel**

Shared nodes maximize density. Dedicated nodes maximize isolation. Virtual nodes
sidestep the tradeoff at the cost of adding another layer of abstraction. Your budget
speaks to density; your SLA speaks to isolation. These are not the same conversation.
Which topology do you default to, and what would make you change your mind?

**Verification**

```
# For dedicated topology, verify isolation:
kubectl get pods -n <vcluster-ns> -o wide
# All pods should show the dedicated node name(s) only
```

**Reference:** [Deploy on AWS EKS](https://www.vcluster.com/docs/vcluster/deploy/control-plane/kubernetes-pod/environment/eks), [Deploy on Google GKE](https://www.vcluster.com/docs/vcluster/deploy/control-plane/kubernetes-pod/environment/gke), [Deploy on Azure AKS](https://www.vcluster.com/docs/vcluster/deploy/control-plane/kubernetes-pod/environment/aks) — You just deployed across topologies. These guides cover cloud-specific considerations for each provider.

**Lifecycle pressure: Infrastructure as Code**

You now have three distinct topology configurations. How do you manage these as your
vCluster count grows from 3 to 30? Is topology a property of the vCluster config, the
platform template, or something set at cluster creation time? Where is that decision
recorded?

---

## M2: Stateful Workloads `[OSS]` `[cloud]`

Run a production-representative stateful workload (PostgreSQL or Redis) inside a vCluster
with persistent storage. Prove the data layer survives operational events.

**Requirements**

- PostgreSQL (or Redis) deployed inside the vCluster as a StatefulSet with a PVC
- Data written to the database and verified queryable before any disruption event
- Data verified still queryable after each of the following, in sequence:
  - Pod rescheduled (delete the database pod manually)
  - vCluster control plane restarted (delete the vCluster control plane pod)
  - Node drained (for cloud: cordon and drain one node)
- StorageClass mapping configured explicitly in `vcluster.yaml` (do not rely on defaults)
- A backup taken via either Velero or a platform snapshot; restore from that backup to a new vCluster and verify data is present

**Pressure you'll feel**

Stateless workloads in vCluster are straightforward — if the pod dies, it comes back
clean. Stateful workloads force you to understand PVC syncing, StorageClass mapping,
and what happens when the host cluster reschedules pods. The PVC exists in two places
simultaneously. Which one is authoritative? What happens if they disagree?

**Verification**

After each disruption event:
```
kubectl exec -it <db-pod> -- psql -U postgres -c "SELECT count(*) FROM test_table;"
# Row count must match pre-disruption count
```

**Lifecycle pressure: Testing**

Your database survived a pod rescheduling. That's one data point. How do you turn that
into a repeatable guarantee? What would a survival test look like that you could run
before every change to your storage configuration?

---

## M3: Security Hardening `[OSS]` `[cloud]`

Harden a vCluster's host RBAC, enforce pod-level security standards, and validate that
your security policies actually block what they claim to block.

**Requirements**

- vCluster syncer's ServiceAccount on the host restricted to the minimum permissions needed; document what you removed and what broke when you removed too much
- Pod Security Standards enforced at the `restricted` level for the virtual cluster's workload namespace; verify a privileged pod is rejected
- ResourceQuota and LimitRange applied inside the virtual cluster; verify a pod that exceeds the quota is rejected
- NetworkPolicy applied on the host namespace isolating the vCluster pods from other host namespaces; verify traffic between two vCluster namespaces on the host is blocked
- A policy violation attempted and confirmed rejected (not just "policy applied" — the block must be demonstrated)

**Pressure you'll feel**

The vCluster API server is isolated. The CNI is shared. The nodes are shared. When you
harden the virtual cluster, you're adding controls at the API layer. But a workload that
can make raw network connections may still reach things your API policy doesn't see.
Where is the actual security boundary? What do the policies you applied actually protect,
and what do they leave open?

**Verification**

```
# Attempt to deploy privileged pod inside vCluster
kubectl apply -f privileged-pod.yaml
# Must be rejected with a policy violation error

# Attempt to exceed ResourceQuota
kubectl apply -f over-quota-deployment.yaml
# Must be rejected

# From a pod in one vCluster's host namespace, attempt to reach a pod in another
curl http://<pod-ip-in-other-vcluster-ns>
# Must time out or be refused if NetworkPolicy is correctly applied
```

**Reference:** [Annotations and Labels Reference](https://www.vcluster.com/docs/vcluster/reference/annotations) — You just hardened RBAC and policies. This reference lists all vCluster annotations and labels that affect security behavior.

**Lifecycle pressure: Testing**

You wrote security policies. How do you prove they still block what they should after
the next vCluster version upgrade? After a platform configuration change? A policy
that was blocking correctly last week may not be blocking correctly today. What does
a security regression test look like here?

---

## M4: Observability & Operations `[OSS → Free]` `[cloud]`

Make a vCluster production-observable: metrics, logs, high availability, and tested
recovery.

**Requirements**

- Prometheus scraping metrics from the vCluster control plane pod; at least `apiserver_request_total` and `etcd_object_counts` visible in a query
- Log aggregation capturing logs from workloads inside the vCluster and from the control plane pod; both accessible in one view
- vCluster control plane configured in HA mode (multiple replicas + leader election `[Free]`); verify leader election is active
- vCluster Pod killed manually; verify the replacement pod comes up and the virtual API server is responsive within a defined time window (set your own SLO — 60s, 30s, whatever fits)
- Backup/restore cycle completed: backup the vCluster state, delete the vCluster, restore it, verify workloads return

**Pressure you'll feel**

Your team depends on this cluster. The vCluster pod crashes at 2am. Do you know
before your users do? Does your alerting fire on the right signal — the API server
being unavailable — or on a proxy metric that lags by minutes? Recovery is not just
"the pod restarted." Recovery is "the API server is responding and workloads are
healthy." How do you instrument that distinction?

**Verification**

- Alert rule defined that fires when `kube_pod_status_phase{pod=~".*vcluster.*"} != 1` for more than 2 minutes; test it by killing the pod and confirming the alert state changes
- `kubectl get nodes` and `kubectl get pods` inside the virtual cluster succeed within your defined SLO window after the control plane pod is terminated and replaced

**Reference:** [OSS vs Free Tier Comparison](https://www.vcluster.com/docs/vcluster/introduction/oss-vs-free) — You just configured HA with leader election, a Free-tier feature. This comparison shows where each tier boundary falls.

**Lifecycle pressure: Version control**

Your monitoring configs, alert rules, and backup schedules are operational
infrastructure. They determine how you find out about failures. Are they versioned?
If someone accidentally changes the alert threshold, how do you know, and how do you
roll it back?

---

## M5: Lifecycle Management `[Optional — Enterprise]` `[cloud]`

> **Note:** This milestone requires Enterprise tier features (sleep/wake policies, auto-delete). It is optional for learners using the Free tier. The concepts (lifecycle cost optimization, idle resource management) are valuable to understand even if you cannot implement them hands-on.

Configure automatic sleep, wake, and deletion policies. Optimize cost at the platform
level.

**Requirements**

- Sleep mode configured to trigger after 30 minutes of inactivity; verify the vCluster enters sleep by waiting or triggering inactivity
- A sleeping vCluster woken by a kubectl command; measure and record the wake latency
- CRON-based sleep schedule configured (e.g., sleep nights and weekends); verify schedule is active
- Auto-delete policy configured for vClusters idle longer than 7 days; verify the policy appears in the platform configuration
- Cost comparison documented: resource consumption of active cluster vs sleeping cluster (control plane pod CPU/memory)

**Pressure you'll feel**

Every idle vCluster consumes control plane resources. Sleep mode reduces that cost but
adds latency — the first `kubectl` after a long sleep may time out before the API
server is ready. Auto-delete saves more but destroys state. Where is the line between
"cost optimization" and "destroying someone's work"? What information would you need
to set that policy responsibly for your organization?

**Verification**

- Trigger sleep manually: `vcluster platform sleep <name>`; verify vCluster pod count drops (control plane scaled to 0 or suspended)
- Run `kubectl get nodes` against the sleeping cluster; measure time from command to response after wake
- Platform-level policy list shows the auto-delete rule; confirm it would apply to a freshly created test cluster after the configured idle window

**Lifecycle pressure: Infrastructure as Code**

Your lifecycle policies are platform-level configuration. Right now they may exist
only in the platform UI or database. If you rebuilt the platform, would these policies
come back automatically? How do you apply them consistently across clusters provisioned
by different teams?

---

---

# Project 5: Ecosystem Integration `[cloud]` `[OSS + Free]`

**Goal:** Stop being a vCluster user and start being a platform builder. Projects 1–4
taught you how vCluster works. Project 5 is about making it work for others.

**Covers:** CI/CD ephemeral environments, GitOps cluster management, multi-tenant platform design, advanced operations.

---

## M1: CI/CD Pipelines `[OSS]` `[cloud]`

Build a GitHub Actions workflow that provisions an ephemeral vCluster per pull request,
deploys the feature branch, runs smoke tests, and tears down on close.

**Requirements**

- GitHub Actions workflow triggers on PR open and synchronize events
- Workflow creates a uniquely named vCluster per PR (e.g., `pr-{number}`)
- Application from the feature branch deployed into the ephemeral cluster
- At least three smoke tests run against the deployed application (HTTP status check, readiness probe confirmation, and one functional assertion)
- Smoke test results posted as a GitHub PR status check (pass/fail visible in the PR)
- On PR close or merge, a separate workflow job deletes the `pr-{number}` vCluster
- Workflow fails clearly (not silently) if vCluster creation times out

**Pressure you'll feel**

Each open PR gets its own cluster. With 5 PRs, that's 5 running clusters. With 20
PRs, that's 20. The cost scales with your team's activity. What safeguards prevent
runaway cluster creation? What's your strategy for PRs that are open but stale — the
branch hasn't been pushed to in a week, but the PR is still open?

**Verification**

- Open a draft PR; observe the workflow create a named vCluster
- Merge the PR; observe the cleanup workflow delete the cluster
- Confirm `vcluster list` shows no `pr-<number>` cluster after cleanup completes

**Reference:** [GitHub Actions PR Environments](https://www.vcluster.com/docs/vcluster/integrations/github-actions/preview-environments) — You just built what this integration guide describes. Worth reading to see what patterns emerged independently.

**Lifecycle pressure: All three threads**

Your CI pipeline creates infrastructure (IaC), deploys code (build), and runs tests
(testing). All three lifecycle threads converge in one workflow file. That file is
version-controlled, but the clusters it creates are not. How do you audit what the
pipeline created, when, and why? How do you test the pipeline itself?

---

## M2: GitOps `[OSS]` `[cloud]`

Manage vCluster lifecycle declaratively using ArgoCD or Flux. The git repository
is the source of truth — cluster existence, configuration, and workloads all derive
from it.

**Requirements**

- ArgoCD (or Flux) installed on the host cluster
- At least two vClusters defined as Helm releases in a git repository; ArgoCD/Flux creates and reconciles them
- One of those vClusters registered as an ArgoCD Application target; workloads deployed to it via ArgoCD from git
- An ApplicationSet (ArgoCD) or Kustomization (Flux) that generates per-environment vClusters from a single template definition
- A drift test: manually delete a resource inside one vCluster; confirm ArgoCD/Flux reconciles it back within its sync interval
- vCluster creation itself managed via GitOps: adding a new cluster definition to the repo must result in cluster creation without any manual CLI command

**Pressure you'll feel**

GitOps means the git repo is the source of truth. But vClusters are often meant to be
ephemeral — spun up for a PR, torn down after a sprint. How do you reconcile "the repo
defines everything that exists" with "this cluster should exist only until the feature
ships"? What does deleting a cluster look like in a GitOps model?

**Verification**

```
# Add a new vCluster manifest to the repo and push
git add clusters/staging.yaml && git commit -m "add staging cluster" && git push

# Observe ArgoCD/Flux sync — no kubectl or vcluster CLI should be needed
argocd app list   # staging application should appear and sync to Healthy
vcluster list     # staging vCluster should be present
```

**Reference:** [ArgoCD Integration](https://www.vcluster.com/docs/platform/integrations/argocd) — You just implemented the GitOps loop this integration supports.

**Lifecycle pressure: Infrastructure as Code**

Your entire platform is now defined in git. What does your repository structure look
like? How do you separate cluster definitions from workload definitions? How do you
review a change that modifies a shared template — one that affects all environments
at once?

---

## M3: Multi-Tenancy Platform `[Free]` `[cloud]`

Design and operate a multi-team vCluster platform. You are now the platform team;
other teams are your users.

**Requirements**

- At least three tenant teams modeled: each with a Platform Project, a team-specific Template, and at least one provisioned vCluster
- Tenant admins (ServiceAccounts representing each team) can provision new vClusters within their project but cannot modify another team's project or its clusters
- Capacity limits enforced per project namespace using Kubernetes ResourceQuotas: a team's namespace cannot exceed a defined CPU and memory allocation; verify a pod deployment that would exceed the quota is rejected
- A change to one team's template does not affect already-running vClusters from that template (verify by inspecting the running cluster's configuration post-template-update)
- A platform-level change (e.g., updating a shared NetworkPolicy) deployed to all tenant clusters; verify it reaches all of them

**Pressure you'll feel**

You're not a vCluster user anymore — you're building the platform that other teams
use. Your users are your customers. They will ask for things you haven't anticipated.
They will work around constraints that feel too tight. They will depend on behaviors
you consider implementation details. What does "platform thinking" look like compared
to the operator mindset you've had in Projects 1–4?

**Verification**

- Run as `team-b` admin: attempt to delete a cluster in `team-a`'s project → must fail
- Run as `team-a` admin: attempt to deploy a pod that would exceed the namespace ResourceQuota → must fail with Forbidden
- Update `team-a`'s template; verify the already-running `team-a` cluster's resource limits have NOT changed

**Reference:** [Platform API Reference](https://www.vcluster.com/docs/platform/api/) — You just built a multi-tenant platform with Projects and Templates. This API reference covers the resources you used programmatically.

**Lifecycle pressure: Testing**

Your platform serves multiple teams. A change to shared infrastructure could affect
all tenants simultaneously. How do you test that a change to one team's template
doesn't produce unexpected behavior in another team's environment? What does a
platform-level integration test suite look like?

---

## M4: Advanced Operations `[OSS]` `[cloud]`

Develop a vCluster plugin that extends syncer behavior. Optionally, explore one
additional advanced operations scenario.

**Requirements**

- A vCluster plugin developed that adds a custom annotation to every Pod synced to the host (e.g., `platform.io/origin-vcluster: <name>`)
- Plugin packaged as a container image and referenced in `vcluster.yaml`
- Plugin active in a running vCluster; deploy a Pod and verify the annotation appears on the host-synced pod
- Plugin survives vCluster restart; annotation present on new pods after restart
- Document one failure mode discovered during development

**Pressure you'll feel**

Each extension couples your platform to code you maintain but did not write. A plugin
that adds an annotation to synced pods must be updated every time the syncer's sync
contract changes. When you choose to extend vCluster, you are choosing a maintenance
surface. The question is not whether the extension works today — it is whether you can
detect when it silently breaks after the next vCluster upgrade.

**Verification**

- Deploy a pod inside the vCluster; verify the custom annotation appears on the host-synced pod
- Restart the vCluster; deploy another pod; verify the annotation is present
- Document the failure mode you discovered

**Lifecycle pressure: All three threads**

Your extensions, plugins, and integrations are custom infrastructure. The plugin
image is a build artifact. The configuration is IaC. The "does it still work after
upgrade" question is a test. How do you manage all three for code you own but
didn't write from scratch?

**Optional extensions** (choose one if time permits):

- **GPU Workload Isolation:** Configure GPU passthrough, schedule GPU-requesting pods, test contention between two vClusters
- **Distro Migration:** Compare K3s (default) and K8s distros — resource consumption, startup time, API surface differences, migration path
- **Cloud-Native Integrations:** cert-manager, external-secrets, or Istio working end-to-end inside a vCluster with documented sync/passthrough config

