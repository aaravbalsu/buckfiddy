# modules/storage/main.tf
resource "azurerm_storage_account" "buckfiddy-storage-account" {
  name                     = "buckfiddystorageaccount"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "buckfiddy-storage-container" {
  name                  = "buckfiddystoragecontainer"
  storage_account_name  = azurerm_storage_account.buckfiddy-storage-account.name
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "mgmt_containers" {
  name                   = "mgmt_containers.zip"
  storage_account_name   = azurerm_storage_account.buckfiddy-storage-account.name
  storage_container_name = azurerm_storage_container.buckfiddy-storage-container.name
  type                   = "Block"
  source                 = "${path.module}/../../container_files/mgmt_containers.zip"
}

resource "azurerm_storage_blob" "app_containers" {
  name                   = "app_containers.zip"
  storage_account_name   = azurerm_storage_account.buckfiddy-storage-account.name
  storage_container_name = azurerm_storage_container.buckfiddy-storage-container.name
  type                   = "Block"
  source                 = "${path.module}/../../container_files/app_containers.zip"
}

resource "azurerm_storage_blob" "ops_containers" {
  name                   = "ops_containers.zip"
  storage_account_name   = azurerm_storage_account.buckfiddy-storage-account.name
  storage_container_name = azurerm_storage_container.buckfiddy-storage-container.name
  type                   = "Block"
  source                 = "${path.module}/../../container_files/ops_containers.zip"
}