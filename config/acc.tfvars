# HOB pilot — Acceptance environment
# Non-sensitive inputs only. Secrets injected by pipeline variable group.

UMICORE_LOCATION = "HOB"
UMICORE_PROJECT  = "NUTANIXDEV"
environment      = "acc"

# Prism Central endpoint for HOB site
# TODO: replace with actual HOB Prism Central VIP (see OQ NW-02)
nutanix_pc_endpoint = "PLACEHOLDER-HOB-PC-VIP"

# Target cluster name in Prism Central
# TODO: replace with actual HOB cluster name
nutanix_cluster_name = "PLACEHOLDER-HOB-CLUSTER-NAME"

# Primary application network subnet name
# TODO: replace with actual VLAN/subnet name from network team
nutanix_subnet_name = "PLACEHOLDER-HOB-SUBNET-NAME"

# Terraform state backend
# TODO: confirm with Wim Schepkens (OQ-08)
backend_resource_group  = "PLACEHOLDER-RG-NAME"
backend_storage_account = "PLACEHOLDER-STORAGE-ACCOUNT"
backend_container       = "nutanix-acc"
backend_key             = "hob/acc.tfstate"
