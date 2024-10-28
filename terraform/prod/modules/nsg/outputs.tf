output "id" {
  description = "The ID of the Network Security Group."
  value       = azurerm_network_security_group.this.id
}

output "name" {
  description = "The name of the Network Security Group."
  value       = azurerm_network_security_group.this.name
}

output "location" {
  description = "The location of the Network Security Group."
  value       = azurerm_network_security_group.this.location
}