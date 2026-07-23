# Monitoring

This document describes the observability stack and how it fits into the GitOps workflow.

## Stack

The monitoring stack is deployed via Argo CD (not Terraform) using the **kube-prometheus-stack** Helm chart:

| Component   | Purpose                                        |
|-------------|------------------------------------------------|
| Prometheus  | Metrics scraping and storage                   |
| Grafana     | Dashboards and visualization                   |
| Alertmanager| Alert routing and deduplication                |
| Node Exporter| Node-level metrics                            |
| kube-state-metrics | Kubernetes object state metrics          |

## Architecture

```text
EKS Cluster
  ├── Prometheus (scrapes metrics)
  │     ├── kubelet / cAdvisor
  │     ├── kube-state-metrics
  │     ├── node-exporter
  │     └── application pods (via annotations)
  ├── Grafana (dashboards)
  │     └── data source: Prometheus
  └── Alertmanager
        └── routes alerts to notification channels
```

## Deployment

The stack is defined in the GitOps repository and reconciled by Argo CD:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: kube-prometheus-stack
  namespace: argocd
spec:
  source:
    repoURL: https://github.com/<your-org>/demo-platform-gitops
    path: charts/kube-prometheus-stack
    helm:
      valueFiles:
        - values.yaml
  destination:
    namespace: monitoring
    server: https://kubernetes.default.svc
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## Metrics Sources

| Source             | Scrape target              | Metrics                  |
|--------------------|----------------------------|--------------------------|
| kubelet            | `https://<node>:10250/metrics` | Node and pod metrics |
| cAdvisor           | `https://<node>:10250/metrics/cadvisor` | Container metrics |
| kube-state-metrics | `kube-state-metrics.kube-system.svc` | K8s object state |
| node-exporter      | `node-exporter.monitoring.svc` | Host metrics        |

## Dashboards

Grafana ships with the standard kube-prometheus-stack dashboards. Add custom dashboards by committing JSON to the GitOps repo and letting Argo CD sync them.

Recommended dashboards:

- Cluster overview (nodes, pods, CPU, memory)
- Karpenter node provisioning
- API server latency and error rate
- Pod resource usage
- Persistent volume usage (EBS CSI)

## Alerting

Define alert rules in the GitOps repo as `PrometheusRule` resources. Route alerts via Alertmanager to:

- Slack (via webhook)
- PagerDuty
- Email

Example alerts:

- `NodeCPUHigh` — node CPU > 80% for 10m
- `PodCrashLooping` — pod restart rate above threshold
- `KarpenterProvisioningFailed` — node provisioning errors
- `PVNearlyFull` — persistent volume > 90% used

## Retention

Configure Prometheus retention in the Helm values:

```yaml
prometheus:
  prometheusSpec:
    retention: 15d
    retentionSize: 50GB
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: ebs-sc
          resources:
            requests:
              storage: 100Gi
```

For long-term storage, consider:

- Amazon Managed Service for Prometheus (remote write)
- Thanos or Mimir for multi-cluster federation
