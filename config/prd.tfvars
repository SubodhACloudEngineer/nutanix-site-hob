# WARNING: Production environment — requires full team
# approval gate before any apply. See pipeline Section 8.7.1 of design document.
#
# HOB pilot — Production environment (workload classification "prd")
# Non-sensitive inputs only. Secrets are NOT stored in this file.
#
# SPRINT 3 SCAFFOLDING: only dev.tfvars is validated this sprint. The values
# below are carried over from dev as scaffolding and are NOT yet confirmed for
# this environment.
#
# ENVIRONMENTS: there are no separate dev/test/prod clusters. The cluster named
# below is PRODUCTION HARDWARE regardless of this filename; `environment` is a
# workload classification and pipeline gating tier, not an infra boundary.
#
# BACKEND: supplied by the pipeline as -backend-config at init time, not here.

UMICORE_LOCATION = "HOB"
UMICORE_PROJECT  = "NUTANIXDEV"
environment      = "prd"

nutanix_pc_endpoint  = "prismcentral-emea.atom.ads"
nutanix_cluster_name = "HOB-CL-DEV1"
nutanix_subnet_name  = "HOB-DEV1-VN-Linux-v196"
