terraform {
  required_providers {
    nutanix = {
      source  = "nutanix/nutanix"
      version = "~> 2.4"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# No azurerm provider block — azurerm is used for the backend only.
# Backend configuration is supplied by the pipeline at terraform init time.
provider "nutanix" {
  username = var.nutanix_username
  password = var.nutanix_password
  endpoint = var.nutanix_pc_endpoint
  port     = 9440
  insecure = var.nutanix_insecure
}
