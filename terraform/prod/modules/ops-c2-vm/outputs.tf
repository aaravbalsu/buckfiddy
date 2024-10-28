output "public_ip_address" {
  value = azurerm_public_ip.ops_c2_vm.ip_address
}

output "vm_id" {
  value = azurerm_virtual_machine.ops_c2_vm.id
}

output "vm_name" {
  value = azurerm_virtual_machine.ops_c2_vm.name
}