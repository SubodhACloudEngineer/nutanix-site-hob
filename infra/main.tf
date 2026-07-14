locals {
  # Default tags applied to all VMs at this site.
  # Individual module blocks can override per-VM.
  common_it_responsible = "infra-team@umicore.com"
}

# The nutanix_vm module is downloaded from the Azure Artifacts feed by the
# pipeline before terraform init runs. It is placed at ./modules/nutanix_vm/
# by the deploy/step-terraform-download-module.yml step template.
# Do NOT commit the modules/ folder — it is populated at build time only.

# ── Example 1: Template-based Windows Server ──────────────────────────────────
# Copy this block and adjust values when requesting a new Windows VM.
#
# module "hob_as_0001" {
#   source = "./modules/nutanix_vm"
#
#   # Location and environment — from tfvars
#   UMICORE_LOCATION = var.UMICORE_LOCATION
#   UMICORE_PROJECT  = var.UMICORE_PROJECT
#   environment      = var.environment
#
#   # VM identity
#   usage_code      = "AS"
#   sequence_number = 1
#
#   # Source: deploy from a Prism Central VM Template (Windows Server 2025)
#   source_type   = "template"
#   template_name = "WIN2025-golden-v1.0"
#
#   # Infrastructure
#   cluster_name = var.nutanix_cluster_name
#   subnet_name  = var.nutanix_subnet_name
#
#   # Compute
#   num_vcpus_per_socket = 2
#   num_cpu_sockets      = 1
#   memory_size_mib      = 4096
#
#   # Guest customisation (Windows)
#   os_type     = "windows"
#   sysprep_xml = var.sysprep_win2025
#
#   # Active Directory
#   ad_join        = true
#   ad_join_domain = "nucleus.atom.ads"
#
#   # Mandatory Nutanix categories (all 10 required — Backup drives Veeam)
#   category_business_unit    = "Manufacturing"
#   category_environment      = var.environment
#   category_criticality      = "High"
#   category_recharge         = "CC-MFG-001"
#   category_primary_function = "ApplicationServer"
#   category_application      = "ExampleApp"
#   category_description      = "HOB manufacturing application server"
#   category_bu_responsible   = "plant-owner@umicore.com"
#   category_it_responsible   = local.common_it_responsible
#   category_backup           = "Gold"
# }

# ── Example 2: Image-based appliance or migrated VM ──────────────────────────
# Use this pattern for appliances or VMs migrated from another platform.
#
# module "hob_as_0002" {
#   source = "./modules/nutanix_vm"
#
#   UMICORE_LOCATION = var.UMICORE_LOCATION
#   UMICORE_PROJECT  = var.UMICORE_PROJECT
#   environment      = var.environment
#
#   usage_code      = "AS"
#   sequence_number = 2
#
#   # Source: deploy from a PC Image Service image (appliance or migrated VM)
#   source_type = "image"
#   image_name  = "LogicMonitor-collector-v34.0.qcow2"
#
#   cluster_name = var.nutanix_cluster_name
#   subnet_name  = var.nutanix_subnet_name
#
#   num_vcpus_per_socket = 4
#   num_cpu_sockets      = 1
#   memory_size_mib      = 8192
#
#   # Appliances: no guest customisation
#   os_type = "appliance"
#
#   category_business_unit    = "IT"
#   category_environment      = var.environment
#   category_criticality      = "High"
#   category_recharge         = "CC-IT-OPS"
#   category_primary_function = "Monitoring"
#   category_application      = "LogicMonitor"
#   category_description      = "LogicMonitor collector appliance HOB"
#   category_bu_responsible   = "it-monitoring@umicore.com"
#   category_it_responsible   = local.common_it_responsible
#   category_backup           = "Silver"
# }
