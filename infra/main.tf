locals {
  # VM identity for the first HOB test VM.
  #
  # The module computes the VM name itself as
  # lower(UMICORE_LOCATION-usage_code-NNNN). We recompute it identically here
  # ONLY to inject the hostname into cloud-init: cloud_init_userdata is an
  # INPUT to the module, so it cannot reference the module's own vm_name output
  # without creating a dependency cycle.
  usage_code      = "AS"
  sequence_number = 1
  vm_name         = lower(format("%s-%s-%04d", upper(var.UMICORE_LOCATION), upper(local.usage_code), local.sequence_number))
}

# ── First HOB VM: hob-as-0001 ─────────────────────────────────────────────────
# EXACTLY ONE VM. No for_each / count. Multi-VM introduces sequence-number
# allocation (open design question OQ-04) and is out of scope — one VM proves
# the delivery chain end to end.
module "hob_as_0001" {
  # The pipeline's deploy/step-terraform-download-module.yml step downloads the
  # nutanix_vm package (version 2.0.3, pinned by the moduleVersion parameter)
  # from the CCoE Azure Artifacts feed and extracts it to
  # infra/modules/nutanix_vm, which .gitignore excludes from commits. For local
  # development, copy or symlink your nutanix-terraform-modules checkout to
  # infra/modules/nutanix_vm (see the repository README).
  #
  # NOTE: no Terraform `version` argument is set here. `version` is only valid
  # for module-registry sources; Terraform rejects it on a local path source
  # like ./modules/nutanix_vm. The version is pinned by the pipeline download.
  source = "./modules/nutanix_vm"

  # Location and project — from config/dev.tfvars
  UMICORE_LOCATION = var.UMICORE_LOCATION
  UMICORE_PROJECT  = var.UMICORE_PROJECT
  environment      = var.environment

  # VM identity → name resolves to hob-as-0001
  usage_code      = local.usage_code
  sequence_number = local.sequence_number

  # Source: clone from a Prism Central Image Service image (Rocky 10), not a
  # template. image_name is a per-VM input (like sizing and categories below),
  # so it is set here rather than in the shared site tfvars.
  source_type = "image"
  image_name  = "Rocky-10-GenericCloud-Base.latest.x86_64.qcow2"

  # Infrastructure placement — resolved from config/dev.tfvars, not hardcoded
  cluster_name = var.nutanix_cluster_name
  subnet_name  = var.nutanix_subnet_name

  # Compute: 2 sockets x 1 core = 2 vCPU, 4 GiB RAM.
  # OS disk: module default (source image's own disk size) — os_disk_size_gib
  # is left unset. Data disks: none (module default []).
  num_cpu_sockets      = 2
  num_vcpus_per_socket = 1
  memory_size_mib      = 4096

  # Guest customisation (Linux). PLAIN YAML — the module base64-encodes it
  # (base64encode(var.cloud_init_userdata)); do NOT pre-encode here.
  os_type             = "linux"
  cloud_init_userdata = templatefile("${path.module}/cloud-init/rocky10.yaml", { hostname = local.vm_name })

  # ── Mandatory Nutanix categories (all 10 required) ──────────────────────────
  # NOTE: eight of the ten categories below currently have only "Test" as an
  # available value in Prism Central, so real business values cannot be used
  # until Umicore populates the category value lists. The module resolves each
  # key+value pair to an ext_id and fails at plan time on any value that does
  # not exist in Prism Central.
  category_business_unit    = "Test"
  category_environment      = "Development"
  category_criticality      = "Test"
  category_recharge         = "Test"
  category_primary_function = "Test"
  category_application      = "Test"
  category_description      = "Test"
  category_bu_responsible   = "Test"
  category_it_responsible   = "Test"

  # UMI-NoBackup is deliberate for this first, throwaway test VM. The Umi_Backup
  # category drives Veeam VBR 13 job assignment automatically; Veeam queries
  # Prism Central and places matching VMs into a backup job. Several
  # near-duplicate values exist in Prism Central (HOB-Agent-Backup vs
  # HOB-AgentBackup, NO-Backup vs UMI-NoBackup) and which values Veeam actually
  # binds to is unconfirmed, so a test VM must not be attached to a real backup
  # schedule.
  category_backup = "UMI-NoBackup"
}
