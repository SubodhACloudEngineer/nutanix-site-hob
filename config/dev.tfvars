# HOB pilot — Development environment (workload classification "dev")
# Non-sensitive inputs only. Secrets are NOT stored in this file.
#
# ENVIRONMENTS: Umicore has no separate dev/test/prod clusters — every Nutanix
# cluster is production hardware, and HOB-CL-DEV1 is a sandbox by convention
# only. `environment` describes the WORKLOAD classification and the pipeline
# gating tier, not an infrastructure boundary.
#
# SUBNET ext_id: nutanix_subnet_name below (HOB-DEV1-VN-Linux-v196) resolves to
# ext_id fb8f567c-e9ea-413d-b8fe-d22abf00a485, confirmed against Prism Central.
# Cross-check this against the subnet ext_id shown in plan output.
#
# API KEY: not stored here. It is supplied via TF_VAR_nutanix_api_key locally
# and from Azure Key Vault secret api-hob-cl-dev1 in the pipeline.
#
# BACKEND: resource group / storage account / container / state key are NOT set
# here — the pipeline passes them as -backend-config arguments at init time
# (see deploy/step-terraform-init.yml).

UMICORE_LOCATION = "HOB"
UMICORE_PROJECT  = "NUTANIXDEV"
environment      = "dev"

# Prism Central endpoint for the HOB site
nutanix_pc_endpoint = "prismcentral-emea.atom.ads"

# Target cluster in Prism Central (production hardware; sandbox by convention)
nutanix_cluster_name = "HOB-CL-DEV1"

# Primary NIC subnet name (ext_id fb8f567c-e9ea-413d-b8fe-d22abf00a485)
nutanix_subnet_name = "HOB-DEV1-VN-Linux-v196"
