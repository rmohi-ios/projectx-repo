# EKS Module

## VPC CNI Prefix Delegation Fix (2026-03-22)

### The Problem

After scaling the EKS cluster back up each day, two DaemonSet pods consistently got stuck in `Pending` state:

- `csi-secrets-store-provider-aws` (kube-system)
- `fluent-bit` (logging)

This happened every time the cluster was scaled down for the day and brought back up the next morning, requiring manual troubleshooting.

### Root Cause

The worker nodes use `t3.medium` instances, which have an AWS ENI-based pod limit of **17 pods per node** (3 ENIs x 6 IPs - 1 = 17).

One node (`ip-10-0-1-90.ec2.internal`) was running all the system workloads:

| Namespace      | Workloads                          | Pod Count |
|----------------|-------------------------------------|-----------|
| cert-manager   | cert-manager, cainjector, webhook  | 3         |
| flux-system    | helm, kustomize, notification, source controllers | 4 |
| elastic-system | elastic-operator                   | 1         |
| karpenter      | karpenter                          | 1         |
| kube-system    | coredns, ebs-csi-controller (x2), aws-node, kube-proxy, ebs-csi-node, csi-secrets-store-csi-driver | 7 |
| monitoring     | prometheus-node-exporter           | 1         |

**Total: 17/17 pods** -- completely full. The `fluent-bit` and `csi-secrets-store-provider-aws` DaemonSet pods had no room to schedule.

### Diagnosis Steps

1. Identified the two Pending pods via `kubectl get pods -A`
2. Ran `kubectl describe pod` on the Pending pods -- event showed: `0/5 nodes are available: 1 Too many pods, 4 node(s) didn't satisfy plugin(s) [NodeAffinity]`
3. Checked pod capacity on all nodes -- confirmed `ip-10-0-1-90` was at 17/17 (t3.medium limit)
4. Verified the other 4 nodes already had their own DaemonSet instances, so the Pending pods could only target the full node
5. Traced the issue to the AWS ENI-based max pod limit on t3.medium instances

### The Fix

Two changes were made to permanently resolve the issue:

#### 1. Enabled VPC CNI Prefix Delegation (`addons.tf`)

Added configuration to the `vpc-cni` EKS addon to enable prefix delegation, which assigns /28 prefixes instead of individual IPs to ENIs:

```hcl
configuration_values = jsonencode({
  env = {
    ENABLE_PREFIX_DELEGATION = "true"
    WARM_PREFIX_TARGET       = "1"
  }
})
```

#### 2. Increased maxPods in Launch Template (`launch-tl.tf`)

Added `maxPods: 110` to the kubelet config in the node user_data so nodes advertise the higher capacity:

```yaml
kubelet:
  config:
    clusterDNS:
      - 172.20.0.10
    maxPods: 110
```

### Result

- Pod capacity per t3.medium node increased from **17 to 110**
- DaemonSet pods now have room to schedule on every node regardless of system workload density
- No more daily troubleshooting required after cluster scale-up

### Notes

- Existing nodes need to be rolled (terminated and replaced) to pick up the new `maxPods` setting from the updated launch template
- Karpenter-managed nodes pick up the change automatically on next provision
- The VPC CNI addon change takes effect immediately upon apply
