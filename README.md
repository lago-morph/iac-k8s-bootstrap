# iac-k8s
Tutorial repository for creating a non-trivial Kubernetes environment in the cloud

# Capabilities

## Overview
### Initial

- Network base
- Cloud-based k8s
- PVCs
- Ingress controller
  - Automated TLS certificates
  - Automated DNS registration
- Service mesh
- Continuous Delivery (CD) (gitops)
- Secrets management
- Monitoring (metrics, logs, tracing)
  - Configured cluster monitoring dashboards (gitops)
    - Integration with all services
    - Alarms
- Event handling (gitops)
- Workflow (gitops)
- Identity management (gitops)
  - Integration with all services

### Later

- Policy management (kyverno)
- Efficient autoscaling (karpenter)
- Image management (Harbor)
- Admin vs. tenant clusters
- Multi-tenant (RBAC + NetworkPolicies)

## Requirements

### Network base
### Cloud-based k8s
### PVCs

Should allow integration with high-durability and availability backing store for persistent volumes.

Should allow for backup of PVCs in an automated way, including with retention policies to limit backup storage requirements.

Monitoring should include number, status, storage used, backup status, and backup storage used (with history).

### Ingress controller

Expose services beyond confines of cluster.

Should be integrated with DNS registration to allow seamless deployment without manually creating DNS records.

Should automatically retrieve (or generate) and associate proper TLS certificates with ingress and allow mandating https as layer 7 protocol.

### Service mesh

Implements zero-trust mTLS between services in the cluster without having to manage a CA or certificates.

Supports high-level tracing without code changes.

May take over interface to ingress through Gateway API.

### Continuous Delivery (CD) (gitops)

Platform-agnostic way of installing and maintaining cluster services.  Get away from temptation to use platform-specific services in Terraform.  NOT set up for tenant use (security is tricky for that).

### Secrets management

Platform-agnostic place to store and retrieve secrets (passwords, access tokens, ssh keys, TLS private keys, etc.).

Needs a central secrets store, and a way to easily access those secrets from within the cluster.  Should have API-based or script-compatible way to store secrets as well.

### Monitoring (metrics, logs, tracing)

  - Configured cluster monitoring dashboards (gitops)
    - Integration with all services
    - Alarms

### Event handling (gitops)

Generic way to consume and redirect events.

Focus is on incoming webhooks, alarms, and scheduled triggers (for cron jobs).

Initial implementation will aggregate alarms from alertmanager and kick off periodic backup/cleanup jobs.

### Workflow (gitops)

Generic way to take action on events, including cron jobs.  Central place to put all automated processes, both ad-hoc and reactive.  Reduces/eliminates need for random shell scripts scattered about.  

Initial implementation for filtering and notification based on alarms and implementing periodic backup/cleanup jobs.

All outgoing notifications should go through workflow.

### Identity management (gitops)

Single sign-on for all cluster services.  Connected to external OIDC provider to allow for enterprise integration.

Each service configured to integrate with identity provider and have appropriate mapping between SSO groups/roles and cluster-service-specific actions.

# Design

- All IaC
  - Terraform for absolute minimum
  - ArgoCD for everything else
- Design to allow different base platforms (e.g., AWS, Azure, local)
  - Terraform modules where tight integration required
  - Isolate platform at as low a level as possible 
    - network, k8s (compute/control plane, user management, API endpoints), PVC, ingress, DNS, vault root token, Keycloak OIDC provider, **maybe** TLS certs
- Network infrastructure standard (or ignored for local)
  - Private/public subnets
  - NAT servers for outgoing traffic from private subnets
  - Cloud provider-specific internet ingress/gateway
- Security not ignored, but also not super-strict
  - Secrets managed properly
  - Do not use single "admin" user for everything (except k8s cluster)
  - SSO
- Well documented

## Cloud-based k8s

Highly-coupled with deployment environment.

- Minikube/kind (?)
- AWS 
- Azure (later)
- GCP (later)

- Dashboard
- IdM integration (w/RBAC)
- Alerts

## PVCs

- on AWS, use EFS - need to provide multiple flavors due to ownership strangeness
- Backups with automated retention policy

- Dashboard
- IdM integration (w/RBAC)
- Alerts

## Ingress controller

- LBC is easy since I already have it set up
- NGINX or Contour are more generic
- Do I want to use Gateway API?

- Dashboard
- IdM integration (w/RBAC)
- Alerts

## Automated TLS certificates

- Automatic with AWS and LBC
- cert-manager + generic ingress more general

- Dashboard
- IdM integration (w/RBAC)
- Alerts

## Automated DNS registration

- External-DNS - tied tightly to registrar - local setup?

- Dashboard
- IdM integration (w/RBAC)
- Alerts

## Service mesh

- For mTLS between services
- Tracing functions
- Choice influences ingress controller

- Dashboard
- IdM integration (w/RBAC)
- Alerts

## Continuous Delivery (CD) (gitops)

- ArgoCD
- Drive through gitops

- Dashboard
- IdM integration (w/RBAC)
- Alerts

## Secrets management

- Vault
- External secrets operator
- Use provider-specific secret store for root token/keys (file for local)

- Dashboard
- IdM integration (w/RBAC)
- Alerts

## Monitoring (metrics, logs, tracing)

- Prometheus
- OTEL
- Loki
- Grafana

- Dashboard
- IdM integration (w/RBAC)
- Alerts

## Configured cluster monitoring dashboards (gitops)

- Grafana
- Alertmanager

- Integration with all services

## Event handling (gitops)

Preconfigured webhook server

- Argo Events

- Dashboard
- IdM integration (w/RBAC)
- Alerts

## Workflow (gitops)

- Argo Workflows

- Dashboard
- IdM integration (w/RBAC)
- Alerts

## Identity management (gitops)

- Keycloak
- Manage users through gitops

