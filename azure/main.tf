provider azurerm {
    features {}
}

# ftstateをバケットに保管する。
terraform {
    #backend "azurerm" {
    #    resource_group_name  = "tfstate"
    #    storage_account_name = "<ストレージ名>"
    #    container_name       = "tfstate"
    #    key                  = "<ストレージキー>"
    #}
}

variable "resource_group_name" {
    type = string
    default = "AzureResource"
    description = ""
}

variable "location" {
    type = string
    default = "japaneast"
    description = ""
}

resource "azurerm_resource_group" "resource_group" {
    name = var.resource_group_name
    location = var.location
}
