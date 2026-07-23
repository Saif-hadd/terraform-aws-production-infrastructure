# Networking

This document describes the VPC and networking architecture used by Demo Platform.

## VPC Design

Each environment gets its own VPC with three subnet tiers:

| Subnet type | Purpose                                  | Kubernetes tag             |
|-------------|------------------------------------------|----------------------------|
| Public      | Internet-facing ALBs, NAT gateway        | `kubernetes.io/role/elb=1` |
| Private     | EKS worker nodes, internal ALBs          | `karpenter.sh/discovery`   |
| Intra       | EKS control plane endpoints (no NAT)     | —                          |

## CIDR Allocation

Subnet CIDRs are derived from the VPC CIDR using `cidrsubnet()`:

| Environment | VPC CIDR      | Private        | Public         | Intra          |
|-------------|---------------|----------------|----------------|----------------|
| `dev`       | `10.10.0.0/16`| `10.10.0.0/20` | `10.10.3.0/24` | `10.10.4.0/24` |
| `staging`   | `10.20.0.0/16`| `10.20.0.0/20` | `10.20.3.0/24` | `10.20.4.0/24` |
| `prod`      | `10.0.0.0/16` | `10.0.0.0/20`  | `10.0.3.0/24`  | `10.0.4.0/24`  |

The newbits and offsets are configurable via the `vpc` module variables.

## NAT Gateway

- A single NAT gateway is deployed by default (`single_nat_gateway = true`) to reduce cost.
- Private and intra subnets route egress traffic through the NAT gateway.
- For production high-availability, set `single_nat_gateway = false` to deploy one NAT gateway per AZ.

## EKS Endpoint

- The EKS public API endpoint is enabled by default (`endpoint_public_access = true`).
- Restrict access by setting `endpoint_public_access_cidrs` to your corporate CIDR ranges.
- For maximum security, set `endpoint_public_access = false` and enable private endpoint access.

## Subnet Discovery Tags

Karpenter and the AWS Load Balancer Controller rely on subnet tags for discovery:

| Tag                         | Applied to        | Used by                     |
|-----------------------------|-------------------|-----------------------------|
| `karpenter.sh/discovery`    | Private subnets   | Karpenter                   |
| `kubernetes.io/role/elb`    | Public subnets    | AWS LB Controller (internet)|
| `kubernetes.io/role/internal-elb` | Private subnets | AWS LB Controller (internal)|

## Security Groups

The EKS module creates two base security groups:

- **Cluster security group** — controls traffic to the EKS control plane
- **Node security group** — controls traffic to worker nodes

The `security` module adds optional ingress rules (e.g., allowing the ALB to reach pods on specific ports). By default, no extra rules are created, keeping the migration path safe.
