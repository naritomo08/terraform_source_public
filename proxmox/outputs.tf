output "virtual_machines" {
  description = "Configured VM information."
  value = {
    for name, vm in proxmox_virtual_environment_vm.vm : name => {
      name         = vm.name
      vm_id        = vm.vm_id
      node_name    = vm.node_name
      ipv4_address = var.virtual_machines[name].ipv4_address
      tags         = vm.tags
    }
  }
}

output "qemu_guest_agent_ipv4_addresses" {
  description = "IPv4 addresses reported by QEMU Guest Agent. This can be empty until the guest agent starts and reports addresses."
  value = {
    for name, vm in proxmox_virtual_environment_vm.vm : name => flatten(vm.ipv4_addresses)
  }
}
