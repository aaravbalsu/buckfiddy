output "public_ip_address" {
  value = azurerm_public_ip.public_ip.ip_address
}

output "vm_id" {
  value = azurerm_virtual_machine.vm.id
}

output "vm_name" {
  value = azurerm_virtual_machine.vm.name
}