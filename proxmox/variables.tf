variable "proxmox_endpoint" {
  description = "Proxmox VE API endpoint URL. Example: https://pve1.example.local:8006/"
  type        = string

  validation {
    condition     = can(regex("^https://.+:8006/?$", var.proxmox_endpoint))
    error_message = "proxmox_endpoint must be an HTTPS URL ending with port 8006, for example https://pve1.example.local:8006/."
  }
}

variable "proxmox_api_token" {
  description = "Proxmox VE API token in the form user@realm!tokenid=secret. Pass it with TF_VAR_proxmox_api_token."
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^[^@!]+@[^@!]+![^=]+=.+$", var.proxmox_api_token))
    error_message = "proxmox_api_token must look like user@realm!tokenid=secret."
  }
}

variable "proxmox_insecure" {
  description = "Skip TLS certificate verification. Use true only for test environments with self-signed certificates."
  type        = bool
}

variable "template_vm_id" {
  description = "Source Cloud-init capable template VM ID."
  type        = number

  validation {
    condition     = var.template_vm_id > 0
    error_message = "template_vm_id must be greater than 0."
  }
}

variable "template_node_name" {
  description = "Proxmox node name where the source template VM exists."
  type        = string

  validation {
    condition     = length(trimspace(var.template_node_name)) > 0
    error_message = "template_node_name must not be empty."
  }
}

variable "target_datastore" {
  description = "Target datastore for cloned VM disks."
  type        = string

  validation {
    condition     = length(trimspace(var.target_datastore)) > 0
    error_message = "target_datastore must not be empty."
  }
}

variable "network_bridge" {
  description = "Proxmox network bridge connected to the VM network device."
  type        = string

  validation {
    condition     = length(trimspace(var.network_bridge)) > 0
    error_message = "network_bridge must not be empty."
  }
}

variable "cloud_init_datastore" {
  description = "Datastore for the Cloud-init disk."
  type        = string

  validation {
    condition     = length(trimspace(var.cloud_init_datastore)) > 0
    error_message = "cloud_init_datastore must not be empty."
  }
}

variable "cloud_init_username" {
  description = "User name created or configured by Cloud-init."
  type        = string

  validation {
    condition     = can(regex("^[a-z_][a-z0-9_-]*[$]?$", var.cloud_init_username))
    error_message = "cloud_init_username must be a valid Linux user name."
  }
}

variable "ssh_public_key_file" {
  description = "Path to the SSH public key file passed to Cloud-init."
  type        = string

  validation {
    condition     = length(trimspace(var.ssh_public_key_file)) > 0
    error_message = "ssh_public_key_file must not be empty."
  }
}

variable "dns_servers" {
  description = "DNS servers passed to Cloud-init."
  type        = list(string)

  validation {
    condition     = length(var.dns_servers) > 0
    error_message = "dns_servers must contain at least one DNS server."
  }
}

variable "default_gateway" {
  description = "Default IPv4 gateway passed to Cloud-init."
  type        = string

  validation {
    condition     = can(cidrhost("${var.default_gateway}/32", 0))
    error_message = "default_gateway must be a valid IPv4 address."
  }
}

variable "vm_tags" {
  description = "Tags applied to all Proxmox VMs."
  type        = list(string)
  default     = ["terraform", "cloud-init"]

  validation {
    condition = alltrue([
      for tag in var.vm_tags : length(trimspace(tag)) > 0
    ])
    error_message = "vm_tags must not contain empty tags."
  }
}

variable "virtual_machines" {
  description = "Map of virtual machines. The map key is used as the VM name and Cloud-init hostname."
  type = map(object({
    vm_id               = number
    node_name           = optional(string, "pve1")
    template_vm_id      = optional(number)
    template_node_name  = optional(string)
    cpu_cores           = optional(number, 2)
    memory_mb           = optional(number, 4096)
    disk_size_gb        = optional(number, 33)
    ipv4_address        = string
    cloud_init_username = optional(string)
    vlan_id             = optional(number)
    tags                = optional(list(string), [])
  }))

  validation {
    condition = alltrue([
      for name, vm in var.virtual_machines :
      can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{0,62}$", name))
    ])
    error_message = "Each virtual_machines key must be a valid DNS hostname label."
  }

  validation {
    condition = alltrue([
      for _, vm in var.virtual_machines :
      vm.vm_id > 0
    ])
    error_message = "Each vm_id must be greater than 0."
  }

  validation {
    condition = alltrue([
      for _, vm in var.virtual_machines :
      vm.template_vm_id == null || vm.template_vm_id > 0
    ])
    error_message = "Each template_vm_id must be null or greater than 0."
  }

  validation {
    condition = alltrue([
      for _, vm in var.virtual_machines :
      vm.template_node_name == null || length(trimspace(vm.template_node_name)) > 0
    ])
    error_message = "Each template_node_name must be null or not empty."
  }

  validation {
    condition = length(distinct([
      for _, vm in var.virtual_machines : vm.vm_id
    ])) == length(var.virtual_machines)
    error_message = "Each vm_id must be unique."
  }

  validation {
    condition = alltrue([
      for _, vm in var.virtual_machines :
      lower(vm.ipv4_address) == "dhcp" || can(cidrhost(vm.ipv4_address, 0))
    ])
    error_message = "Each ipv4_address must be \"dhcp\" or valid IPv4 CIDR notation, for example 192.168.1.101/24."
  }

  validation {
    condition = alltrue([
      for _, vm in var.virtual_machines :
      vm.cloud_init_username == null || can(regex("^[a-z_][a-z0-9_-]*[$]?$", vm.cloud_init_username))
    ])
    error_message = "Each cloud_init_username must be null or a valid Linux user name."
  }

  validation {
    condition = alltrue([
      for _, vm in var.virtual_machines :
      vm.vlan_id == null || (vm.vlan_id >= 1 && vm.vlan_id <= 4094)
    ])
    error_message = "Each vlan_id must be null or a number from 1 to 4094."
  }

  validation {
    condition = alltrue(flatten([
      for _, vm in var.virtual_machines : [
        for tag in vm.tags : length(trimspace(tag)) > 0
      ]
    ]))
    error_message = "Each VM tag must not be empty."
  }
}
