# Monitoring

This document describes how monitoring fits into the platform architecture. The monitoring stack itself is **not** deployed by this Terraform repository — it belongs to the GitOps layer reconciled by Argo CD. This document explains the intended design and how the infrastructure layer supports it.

## Design Principle

This repository creates the AWS infrastructure and IAM foundation. Monitoring components (Prometheus, Grafana, alerting) are Kubernetes workloads and therefore belong in the GitOps repository, not in Terraform.

## Recommended Stack

A typical production setup uses the **kube-prometheus-stack** deployed via Argo CD:

| Component         | Purpose                                        |
|-------------------|------------------------------------------------|
| Prometheus        | Metrics scraping and storage                   |
| Grafana           | Dashboards and visualization                   |
| Alertmanager      | Alert routing and deduplication                |
| Node Exporter     | Node-level metrics                             |
| kube-state-metrics| Kubernetes object state metrics                |

## How This Repository Supports Monitoring

The infrastructure layer provides the foundation that monitoring depends on:

| Provided by this repo             | Used by monitoring for                          |
|-----------------------------------|-------------------------------------------------|
| EKS cluster                       | Hosting Prometheus and Grafana pods             |
| Private subnets                   | Running monitoring pods without public exposure |
| Karpenter node role + SQS queue   | Provisioning nodes for monitoring workloads     |
| IRSA pattern                      | Template for granting monitoring pods AWS access (e.g., CloudWatch) |
| EBS CSI IRSA role                 | Persistent storage for Prometheus data          |
| Node security group               | Controlling access to scrape targets            |

## IAM Considerations

If monitoring workloads need AWS access (e.g., scraping CloudWatch metrics), follow the same IRSA pattern used by the EBS CSI and Load Balancer Controller roles:

1. Create an IAM policy in the `iam` module
2. Create an IRSA role in the `irsa` module scoped to the monitoring ServiceAccount
3. Attach the policy to the role in the environment `main.tf`
4. Annotate the ServiceAccount in the GitOps repository with the role ARN

This keeps the pattern consistent: Terraform owns IAM, GitOps owns the workload.

## What This Repository Does Not Include

- Prometheus / Grafana Helm charts or manifests
- Alert rules or `PrometheusRule` resources
- Dashboard JSON definitions
- Alertmanager routing configuration
- Long-term metrics storage (Amazon Managed Service for Prometheus, Thanos, Mimir)

These all belong in the GitOps repository. This document exists to document the intended architecture and show how the infrastructure layer connects to it.
