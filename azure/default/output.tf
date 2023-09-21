output "vm01-publicip" {
  value       = azurerm_public_ip.main.ip_address
  description = ""
}