# Olaba SENAITE on Google Cloud

Production-oriented reference architecture and Infrastructure as Code (IaC) for running SENAITE LIMS on Google Cloud with Cloudflare DNS/proxy.

## What this package contains

- `terraform/` — Google Cloud + Cloudflare infrastructure
- `k8s/base/` — shared Kubernetes objects
- `k8s/tenant-example/` — example per-tenant SENAITE stack
- `scripts/` — helper scripts and onboarding examples

## Important architectural choice

SENAITE is built on Plone/Zope and commonly scales using **ZEO** plus multiple application clients, rather than as a single stateless web app. Because of that, the safest SaaS pattern is:

- **shared GKE platform**
- **dedicated namespace per lab/tenant**
- **dedicated ZEO storage per tenant**
- **2+ SENAITE client pods per tenant**
- **separate hostname per tenant** (for example `lab01.olaba-lis.com`)

This avoids risky cross-tenant data mixing and makes backup, restore, upgrades, and incident isolation much easier.

## Target topology

- Cloudflare DNS + proxy in front of the service
- Google Cloud regional GKE Autopilot cluster
- global static public IP for ingress
- private VPC + Cloud NAT
- Secret Manager for sensitive values
- Artifact Registry for images
- Backup for GKE for cluster workload backup
- Per-tenant Kubernetes namespace and SENAITE stack
- Optional Cloud SQL reserved for future platform metadata / external integrations

> Note: The sample tenant deployment expects a working SENAITE-compatible image. Image build and deep SENAITE application tuning still need to be validated against your exact version, add-ons, and storage layout.

## Suggested rollout phases

### Phase 1 — first 10 labs

- one regional Autopilot cluster
- 2 SENAITE app replicas per tenant
- 1 ZEO pod per tenant backed by regional persistent disk
- 1 ingress and 1 hostname per tenant
- daily backups + PITR for any external PostgreSQL usage

### Phase 2 — 25 to 40 labs

- shard tenants by business unit or geography across 2 clusters
- introduce separate prod and staging projects if not already split
- enable Binary Authorization / signed images in CI
- formalize tenant onboarding automation

### Phase 3 — 50 to 100 labs

- multiple clusters by region or tenant tier
- separate platform and tenant projects if governance requires it
- blue/green or canary upgrades per tenant cohort
- DR cluster in second region for cold-standby recovery runbooks

## Quick start

1. Create or choose a Google Cloud project.
2. Fill `terraform/terraform.tfvars` from `terraform/terraform.tfvars.example`.
3. Create a service account for Terraform with sufficient permissions.
4. Run:

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

5. Build and push your SENAITE image to Artifact Registry.
6. Get cluster credentials from Terraform outputs.
7. Apply Kubernetes manifests for the first tenant.
8. Point Cloudflare proxied DNS to the load balancer IP.

## Onboarding a new lab

- copy `k8s/tenant-example`
- change namespace, host, storage size, image tag, secret names
- apply manifests
- create DNS record `labXX.olaba-lis.com`
- restore from backup if this is a migration tenant

## Files you will almost certainly customize

- `terraform/variables.tf`
- `terraform/terraform.tfvars.example`
- `k8s/tenant-example/*.yaml`
- image reference inside tenant deployment
- SENAITE environment variables and add-ons

## Security baseline in this design

- Cloudflare proxy enabled
- Full (strict) TLS mode expected
- private cluster nodes
- Workload Identity for GKE
- Secret Manager instead of plaintext secrets in git
- GKE Autopilot security defaults
- NetworkPolicies enabled in cluster
- Artifact Registry image scanning
- optional Binary Authorization toggle in Terraform

