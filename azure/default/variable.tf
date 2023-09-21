variable "resource_group_name" {
  type        = string
  default     = "AzureResource"
  description = ""
}

variable "location" {
  type        = string
  default     = "japaneast"
  description = ""
}

variable "virtual_network_name" {
  type        = string
  default     = "VirtualNetwork"
  description = ""
}

variable "vm01-vmname" {
  type        = string
  default     = "vm01"
  description = ""
}

variable "vm01-network_interface_name" {
  type        = string
  default     = "vm01-public"
  description = ""
}

variable "public-securitygroup" {
  type        = string
  default     = "public-securitygroup"
  description = ""
}

variable "vm01-publicip" {
  type        = string
  default     = "vm01-publicip"
  description = ""
}

variable "vm01-hostname" {
  type        = string
  default     = "vm01"
  description = ""
}

variable "vm01-storagename" {
  type        = string
  default     = "vm01-sdisk"
  description = ""
}
