# VM Provisioning Runbook — HOB Nutanix Site

Audience: engineers requesting new VMs at the Hoboken (HOB) Nutanix site via the `nutanix-site-hob` IaC repository.

---

## 1. How to request a new VM

### Step-by-step

1. **Clone the repo and create a feature branch**

   ```bash
   git clone https://github.com/SubodhACloudEngineer/nutanix-site-hob.git
   cd nutanix-site-hob
   git checkout -b feat/add-hob-as-XXXX
   ```

2. **Uncomment an example module block in `infra/main.tf`**

   Two commented-out examples are provided — one for a template-based Windows Server and one for an image-based appliance. Copy the relevant block, uncomment it, and rename it (e.g. `module "hob_as_0003"`).

3. **Fill in all 10 mandatory Nutanix categories**

   Every VM block must have all 10 category fields set. The `Backup` category is especially critical — it drives automatic Veeam VBR 13 job assignment:

   | Category | Example | Notes |
   |----------|---------|-------|
   | `category_business_unit` | `"Manufacturing"` | BU that owns the workload |
   | `category_environment` | `var.environment` | use the variable — never hardcode |
   | `category_criticality` | `"High"` | High / Medium / Low |
   | `category_recharge` | `"CC-MFG-001"` | Cost centre code |
   | `category_primary_function` | `"ApplicationServer"` | Role of the VM |
   | `category_application` | `"SAP-ERP"` | Application name |
   | `category_description` | `"HOB SAP application server"` | Free text |
   | `category_bu_responsible` | `"plant-owner@umicore.com"` | BU contact |
   | `category_it_responsible` | `local.common_it_responsible` | Usually the local |
   | `category_backup` | `"Gold"` | **Drives Veeam job — do not omit** |

4. **Check the sequence number before using it**

   Log in to Prism Central for the HOB site and check which VM names already exist. The `sequence_number` in the module block must be unique across all VMs with the same `usage_code`.

5. **Open a PR**

   Push your branch and open a pull request targeting `main`. The GitHub Actions `terraform-validate` workflow runs automatically and validates formatting and syntax. The ADO validate pipeline (`azure-pipelines-validate.yml`) also runs and posts the Terraform plan output as a PR comment.

6. **Review the plan, then merge**

   Check the plan comment on the PR carefully — confirm that only the expected VM(s) are being created and that categories look correct.

7. **Trigger the ci-cd pipeline manually**

   After merging, go to Azure DevOps → Pipelines → `azure-pipelines-cicd` → **Run pipeline**. Select:
   - `environment`: the target tier (start with `tst`)
   - `action`: `apply`
   - `moduleVersion`: the version of `nutanix_vm` to use

   For `prd` and `acc`, the pipeline pauses for manual approval before applying.

---

## 2. How to check what the pipeline will do before approving

The **Plan** stage publishes a frozen plan artifact named `tfplan-hob-{env}`.

To review it before clicking **Approve**:

1. Go to the pipeline run in Azure DevOps.
2. Click **Artifacts** → download `tfplan-hob-{env}`.
3. The plan output is also printed in the **terraform plan** task log — expand it in the pipeline UI.
4. Confirm:
   - Only the expected VMs are listed under `# to add`
   - No existing VMs appear under `# to destroy` unexpectedly
   - All 10 Nutanix categories are present and correct on each new VM
   - The correct cluster and subnet names appear

---

## 3. How to import a migrated VM (Nutanix Move)

When a VM has been migrated by **Nutanix Move** and now exists in Prism Central but is not yet tracked in Terraform state, use the import script to bring it under management.

1. **Get the VM UUID from Prism Central**

   In the Prism Central UI: Virtual Infrastructure → VMs → click the VM → copy the UUID from the URL or the VM details panel.

2. **Add the module block to `infra/main.tf`**

   Use `source_type = "image"` and set `image_name` to the image the VM was deployed from (or any valid image — it is not re-deployed on import). Fill in all 10 mandatory categories.

3. **Create an import manifest**

   ```json
   [
     {
       "terraform_address": "module.hob_as_0013.nutanix_virtual_machine.this[0]",
       "vm_uuid":           "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
       "vm_name":           "hob-as-0013"
     }
   ]
   ```

   Save this as `import-manifest.json` (not committed — it contains UUIDs).

4. **Run a dry-run first**

   ```bash
   ./scripts/import-migrated-vms.sh \
     --manifest import-manifest.json \
     --working-dir infra \
     --dry-run
   ```

5. **Run the real import**

   ```bash
   ./scripts/import-migrated-vms.sh \
     --manifest import-manifest.json \
     --working-dir infra
   ```

6. **Review category drift**

   ```bash
   cd infra && terraform plan -var-file="../config/tst.tfvars"
   ```

   Migrated VMs will show Nutanix category differences — they had no IaC-managed categories before. Review and confirm, then apply to enforce the HLD category set.

7. **Apply**

   ```bash
   cd infra && terraform apply -var-file="../config/tst.tfvars"
   ```

   Or trigger the ci-cd pipeline with `action=apply`.

---

## 4. Smoke test interpretation

The smoke test runs automatically after every `apply` in the ci-cd pipeline. It performs two checks:

| Check | PASS | FAIL | SKIP |
|-------|------|------|------|
| **Naming convention** | VM name matches `{SITE}-{CODE}-{NNNN}` | Name does not match | `vm_name_override` was used |
| **IP reachability** | RDP (3389) or SSH (22) responds within 5 attempts | Port not reachable after 5 × 10 s retries | No IP reported yet / appliance OS type |

### Interpreting failures

- **FAIL on naming**: Check that `usage_code` and `sequence_number` in the module block are correct and match the intended name.
- **FAIL on IP**: The VM is likely still completing first boot or Nutanix Guest Tools (NGT) is still installing. Wait 2–5 minutes and re-run the smoke test step manually, or check the VM console in Prism Central.
- **SKIP on IP**: NGT has not yet reported the IP back to Prism Central — this is normal for the first 2–3 minutes after first boot. The ci-cd pipeline marks the smoke test step as `continueOnError: true`, so the deployment is not rolled back. Check the VM IP in Prism Central and retry connectivity manually.

A smoke test failure does **not** roll back the VM. It is a signal for the engineer to investigate.
