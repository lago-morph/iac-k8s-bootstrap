# Objective

The objective of this project is to provide a non-trivial yet approachable base for building a real Kubernetes environment.

This base can then be used as the basis of some blog posts about how and why things are set up the way they are.

## Features:

Usability:

- Docker container with necessary tools already installed

Security:

- RBAC template based on roles of cluster admin, operator, or a member of a user group (e.g., different developer teams) 
- SSO pointing at external OIDC provider (AD used in this example)
  - Gitops mapping between external groups and cluster roles
  - SSO to IdP (Keycloak)

Bootstrap:

All provider-specific configuration done during bootstrap.  Would appreciate contributions to build bootstrap for Azure, GCP, and possibly minikube/KinD (how to handle ingress, automated DNS, and TLS cert?).

- Bootstrap on cloud platform (currently AWS) with the following capabilities:
- PVC using cloud storage
- External DNS and TLS wildcard certificate (assuming domain registered in cloud account)
- ArgoCD set up to use gitops (SSO/RBAC included)

Basic capabilities needed for real clusters:

- Ingress with automated DNS and TLS
- Centralized secrets management (RBAC included)
- Directory of services ("portal")

Observability:

- Log aggregation
- Prometheus/grafana (SSO/RBAC integrated)
  - Operator/admin-focused dashboards
  - Basic cluster health
  - Specific dashboard for each installed service
  - Config/dashboards in git repo

# STATUS

## Done

- Docker container with all necessary tools (and to allow isolation from other k8s environments)
- Install EKS cluster using eksctl
- Create TLS wildcard cert
- Install LBC
- Install ArgoCD with ingress (no Project or Repository)

## Next 

- Reorganize bootstrap to make it easy to slot in Azure/GCP versions
- Reorganize ArgoCD
  - Helm chart in argocd
  - Repository (points to iac-k8s-platform)
  - Application (points to iac-k8s-platform/config)
- iac-k8s-platform
  - Create iac-k8s-platform repository
  - "platform" configuration
    - Project (in config/projects)
    - ApplicationSet (in config/applicationsets) pointing at directory "platform"
  - "apps" configuration
    - Project (in config/projects)
    - Repository (pointing at iac-k8s-apps)
    - ApplicationSet (in config/applicationsets) pointing at Repository iac-k8s-apps directory /
- iac-k8s-apps
  - nginx

## Then

- Rename repository iac-k8s to iac-k8s-bootstrap
- Static text portal that links to all the stuff installed
- ESO using k8s as secret store
- Set up AWS AD for OIDC master (this is manual)
  - Add AWS AD link portal
- Keycloak (iac-k8s-platform/platform/keycloak/helm)
  - Terraform config (platform/keycloak/server)
  - Add Keycloak link to portal
  - SSO for Keycloak (platform/keycloak/clients/keycloak)
  - SSO for ArgoCD (platform/keycloak/clients/argocd)

## Later

- Portal application to replace static text page
  - Possibly do this with ArgoCD using one of:
    - [UI Extensions](https://argo-cd.readthedocs.io/en/stable/developer-guide/extensions/ui-extensions/)
    - [Add external URL] (https://argo-cd.readthedocs.io/en/stable/user-guide/external-url/)
    - [Deep links](https://argo-cd.readthedocs.io/en/stable/proposals/deep-links/)
    - ArgoCD already does this is a non-obvious way in the list of Applications (shows a link to the ingress)
- Argo Workflows
- Argo Events
- k8s role RBAC to allow direct cluster access by teams (or multi-cluster)
- karpenter
- Alarms (alertmanager)
- Demo applications w/SSO integration (wordpress)

## TODO

### Annoyances

- docker - tab-completion for kubectl, git, aws, eksctl, helm
- docker - background/foreground color for docker ttys
- PVC - storageclasses for uid 999, 1000, 1001

### Tests

- PVC - does it work at all?

# Capabilities

## Overview

### Bootstrap

- Network base
- Cloud-based k8s
- PVCs
- Ingress controller
  - Automated TLS certificates
  - Automated DNS registration

### Base gitops

- Continuous Delivery (CD) (gitops)

### Platform

- Secrets management
- Identity management (IdP) (gitops)
  - Integrate with CD

### Workflow

- Event handling (gitops)
- Workflow (gitops)
  - Integrate with IdP

### Monitoring

- Monitoring (metrics, logs, tracing)
  - Configured cluster monitoring dashboards (gitops)
    - Integration with all services
    - Alarms

### Later

- More sophisticated secrets management, integrated with IdP
- Service mesh
- Policy management (kyverno)
- Efficient autoscaling (karpenter)
- Image management (Harbor)
- Multicluster (Admin vs. tenant clusters)
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
  - Cloud-provider-specific config for bootstrap
    - Allow slotting in different cloud provider bootstrap methods
  - ArgoCD for everything else
- Design to allow different base platforms (e.g., AWS, Azure, local)
  - Isolate platform at as low a level as possible 
    - Prefer using provider-specific CLI tools
    - Can use Terraform if absolutely required
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
- IdP integration (w/RBAC)
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

- Initial repository is iac-k8s-bootstrap
  - No gitops here
  - Only reasons to come back to this repo
    - Change ArgoCD Helm chart values
    - Update/change platform-specific components
      - EKS addons (including external-dns)
      - LBC
      - Wildcard cert
  - ArgoCD resources:
    - admin Project (allow creating in any namespace)
    - admin Repository (iac-k8s-admin)
    - admin Application (points at iac-k8s-admin/config directory)
- There is one repo for platform (iac-k8s-admin)
  - config directory has entries for each gitops repo
    - config/platform (platform Project uses admin Repo, platform ApplicationSet)
    - config/team-whatever (team-whatever Project - can only deploy to namespaces `team-whatever-*` whitelisted resources allowed, team-whatever Repo, team-whatever Application pointing at iac-k8s-team-whatever/config)
- There are "n" repos for applications (one per team, iac-k8s-team-whatever)
  - create nginx default deployment as template

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

