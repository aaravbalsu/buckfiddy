output "mgmt_containers_blob_url" {
  value = azurerm_storage_blob.mgmt_containers.url
}

output "app_containers_blob_url" {
  value = azurerm_storage_blob.app_containers.url
}

output "ops_containers_blob_url" {
  value = azurerm_storage_blob.ops_containers.url
}