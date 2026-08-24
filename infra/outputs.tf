output "vm_name" {
  description = "Computed name of the provisioned VM (hob-as-0001). The pipeline smoke-test stage consumes this — an unset value would fail the smoke test silently."
  value       = module.hob_as_0001.vm_name
}

output "vm_uuid" {
  description = "Prism Central ext_id (UUID) of the provisioned VM."
  value       = module.hob_as_0001.vm_uuid
}

output "vm_ip" {
  description = <<-EOT
    Primary learned IPv4 address of the provisioned VM.

    The module currently returns NULL for this BY DESIGN: the correct provider
    attribute path for the learned guest IP on nutanix_virtual_machine_v2 is
    not yet confirmed, and a wrong path is a static error terraform validate
    cannot suppress. It will be confirmed from the first real apply, hardcoded
    in the module, and released as module 2.1.0.
  EOT
  value       = module.hob_as_0001.vm_ip
}
