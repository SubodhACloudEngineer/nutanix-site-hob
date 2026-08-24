terraform {
  required_providers {
    nutanix = {
      source = "nutanix/nutanix"
      # Pinned exactly. 2.4.1 is published upstream but marked "Invalid
      # Release" in the provider changelog, so a range such as "~> 2.4" can
      # resolve to that broken build. 2.4.2 is also the first release that
      # supports api_key authentication for Prism Central.
      version = "2.4.2"
    }
  }
}

# No azurerm provider — the azurerm backend is built into Terraform core and
# needs no provider. Backend configuration is supplied by the pipeline at
# terraform init time (see deploy/step-terraform-init.yml).
provider "nutanix" {
  api_key  = var.nutanix_api_key
  endpoint = var.nutanix_pc_endpoint
  port     = 9440
  insecure = var.nutanix_insecure
}
