resource "proxmox_virtual_environment_vm" "vm" {
  for_each = var.virtual_machines

  name        = each.key
  description = "Managed by Terraform"
  tags        = distinct(concat(var.vm_tags, each.value.tags))

  node_name = each.value.node_name
  vm_id     = each.value.vm_id

  clone {
    vm_id        = coalesce(each.value.template_vm_id, var.template_vm_id)
    node_name    = coalesce(each.value.template_node_name, var.template_node_name)
    datastore_id = var.target_datastore
    full         = true
    retries      = 2
  }

  agent {
    enabled = true

    wait_for_ip {
      ipv4 = true
    }
  }

  cpu {
    cores = each.value.cpu_cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = each.value.memory_mb
  }

  disk {
    datastore_id = var.target_datastore
    interface    = "scsi0"
    size         = each.value.disk_size_gb
    discard      = "on"
    iothread     = true
  }

  initialization {
    datastore_id = var.cloud_init_datastore
    upgrade      = false

    dynamic "dns" {
      for_each = lower(each.value.ipv4_address) == "dhcp" ? [] : [var.dns_servers]

      content {
        servers = dns.value
      }
    }

    ip_config {
      ipv4 {
        address = each.value.ipv4_address
        gateway = lower(each.value.ipv4_address) == "dhcp" ? null : var.default_gateway
      }
    }

    user_account {
      username = coalesce(each.value.cloud_init_username, var.cloud_init_username)
      keys     = [trimspace(file(pathexpand(var.ssh_public_key_file)))]
    }
  }

  network_device {
    bridge  = var.network_bridge
    model   = "virtio"
    vlan_id = each.value.vlan_id
  }

  operating_system {
    type = "l26"
  }

  on_boot       = true
  scsi_hardware = "virtio-scsi-pci"
  started       = true
}
