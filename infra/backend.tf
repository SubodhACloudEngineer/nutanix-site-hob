terraform {
  backend "azurerm" {
    # These values are intentionally left empty here.
    # They are provided by the pipeline via -backend-config flags during
    # terraform init, reading from the environment-specific .tfvars file.
    # See deploy/step-terraform-init.yml for the actual values.
    # DO NOT hardcode real values here — this file is committed to source control.
  }
}
