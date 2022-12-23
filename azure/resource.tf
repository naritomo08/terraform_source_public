# resource_group

resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.location
}

# virtual_network

resource "azurerm_virtual_network" "virtualNetwork" {
  name                = var.virtual_network_name
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
  address_space       = ["10.0.0.0/23"]
}

# subnet

resource "azurerm_subnet" "Public" {
  name                 = "Public"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtualNetwork.name
  address_prefixes     = ["10.0.0.0/25"]
}

resource "azurerm_subnet" "Private" {
  name                 = "Private"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtualNetwork.name
  address_prefixes     = ["10.0.0.128/25"]
}

# network_security_group(public)

resource "azurerm_network_security_group" "main" {
  name                = var.public-securitygroup
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
}

# azurerm_network_security_rule(public RDP Accept)

# 自分のパブリックIP取得
data "http" "ifconfig" {
  url = "http://ipv4.icanhazip.com/"
}

variable "allowed_cidr" {
  default = null
}

locals {
  myip         = chomp(data.http.ifconfig.body)
  allowed_cidr = (var.allowed_cidr == null) ? "${local.myip}/32" : var.allowed_cidr
}

resource "azurerm_network_security_rule" "PublicRDP" {
  name                        = "RDP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = local.allowed_cidr
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.main.name
}

# PublicSubnetとNSGの関連付け

resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = azurerm_subnet.Public.id
  network_security_group_id = azurerm_network_security_group.main.id
}

# network_interface(vm01)

resource "azurerm_network_interface" "main" {
  name                = var.vm01-network_interface_name
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.Public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

# public_ip(vm01)

resource "azurerm_public_ip" "main" {
  name                = var.vm01-publicip
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method   = "Static"
}

# virtual_machine(vm01)

resource "azurerm_virtual_machine" "main" {
  name                  = var.vm01-vmname
  location              = var.location
  resource_group_name   = azurerm_resource_group.resource_group.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_DS1_v2"
  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  storage_os_disk {
    name              = var.vm01-storagename
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = var.vm01-hostname
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = true
  }
}