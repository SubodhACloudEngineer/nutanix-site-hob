# nutanix-site-hob

Terraform Infrastructure-as-Code for VM provisioning at the **Hoboken (HOB)** Nutanix AHV site.

## Overview

| Attribute | Value |
|-----------|-------|
| Site code | HOB (pilot site — first Nutanix site to be onboarded) |
| ADO project | IS.NUTANIXDEV (development/sandbox environment) |
| Module source | *Terraform Modules - Nutanix* repo in the Cloud Center of Excellence project |
| Environment tiers | `prd`, `acc`, `tst`, `dev` (see `config/`) |

## Repository structure

```
.
├── config/         Variable files per environment (.tfvars, one file per tier)
├── deploy/         Centrally managed pipeline step templates (DO NOT MODIFY)
├── docs/           Documentation
├── infra/          Terraform IaC — root module consumed by the pipelines
├── network/        Network configurations (Phase 2 scope)
└── security/       Security configurations
```

## Pipelines

Two Azure DevOps pipelines are wired to this repository:

| Pipeline | Trigger | Effect |
|----------|---------|--------|
| **validate** | PR from a feature branch targeting `main` | Runs `terraform validate` and `terraform plan` — read-only, no changes applied. Provides early feedback before merge. |
| **ci-cd** | Merge to `main` | Runs `terraform plan` followed by `terraform apply` after manual approval. Requires an approver sign-off in the ADO environment gate. |

### Triggering the validate pipeline

Raise a pull request from a feature branch targeting `main`. The validate pipeline runs automatically and posts its result back to the PR.

### Triggering the ci-cd pipeline

Merge the approved PR to `main`. The pipeline picks up the merge commit, plans, waits for the configured approver, then applies.

## Module source

The `nutanix_vm` module is published as a Universal Package to the Azure Artifacts feed in the *Cloud Center of Excellence* ADO project. The `deploy/step-terraform-download-module.yml` step template downloads the pinned version into `infra/modules/nutanix_vm/` at pipeline run time. `infra/main.tf` therefore references the module at `source = "./modules/nutanix_vm"`.

### Local development

For local `terraform` runs the module must resolve at the same path the pipeline uses — `infra/modules/nutanix_vm`. Copy or symlink your `nutanix-terraform-modules` checkout into place, for example:

```bash
ln -s ../../nutanix-terraform-modules/nutanix_vm infra/modules/nutanix_vm
```

`infra/modules/` is excluded by `.gitignore`, so the copied or symlinked module is never committed.

## Environment variable files

Each environment tier has a corresponding variable file under `config/`:

| File | Environment |
|------|-------------|
| `config/prd.tfvars` | Production |
| `config/acc.tfvars` | Acceptance |
| `config/tst.tfvars` | Test |
| `config/dev.tfvars` | Development |

Sensitive values (Nutanix credentials, Sysprep XML) are injected at pipeline run time via ADO variable groups — they are never committed to this repository.
