# ── From config/*.tfvars ──────────────────────────────────────────────────────

variable "UMICORE_LOCATION" {
  type = string
}

variable "UMICORE_PROJECT" {
  type = string
}

variable "environment" {
  type = string
  validation {
    condition     = contains(["prd", "tst", "acc", "dev"], var.environment)
    error_message = "environment must be one of: prd, tst, acc, dev"
  }
}

variable "nutanix_pc_endpoint" {
  type        = string
  description = "Prism Central VIP"
}

variable "nutanix_cluster_name" {
  type        = string
  description = "Target AHV cluster name"
}

variable "nutanix_subnet_name" {
  type        = string
  description = "Primary NIC subnet name"
}

# ── Injected as TF_VAR_* by pipeline (secrets — never in .tfvars files) ──────

variable "nutanix_api_key" {
  description = "API key for Prism Central authentication. Sourced from Azure Key Vault secret api-<cluster-name> in the pipeline; supplied via TF_VAR_nutanix_api_key locally. Never commit a value."
  type        = string
  sensitive   = true
}

variable "nutanix_insecure" {
  type    = bool
  default = false
}

variable "sysprep_win2025" {
  type      = string
  sensitive = true
  default   = null
}

variable "sysprep_win2022" {
  type      = string
  sensitive = true
  default   = null
}

# ── Backend variables ─────────────────────────────────────────────────────────
# Declared here so terraform plan does not error even though these are passed
# to terraform init, not apply.

variable "backend_resource_group" {
  type    = string
  default = ""
}

variable "backend_storage_account" {
  type    = string
  default = ""
}

variable "backend_container" {
  type    = string
  default = ""
}

variable "backend_key" {
  type    = string
  default = ""
}
