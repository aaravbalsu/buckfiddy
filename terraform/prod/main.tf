# Setting up Azure Resource Manager with the appropriate credentials
provider "azurerm" {
    features {}

    subscription_id = var.subscription_id
    client_id = var.client_id
    client_secret = var.client_secret
    tenant_id = var.tenant_id
}


# Setting up the buckfiddy Resource Group in Azure
resource "azurerm_resource_group" "buckfiddy" {
    name = var.resource_group_name
    location = var.location
}

# Setting up the networking layers in Azure
# One VNet containing three subnets for the different components at play
resource "azurerm_virtual_network" "buckfiddy-vnet" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.buckfiddy.location
  resource_group_name = azurerm_resource_group.buckfiddy.name
}

resource "azurerm_subnet" "buckfiddy-subnet" {
  name                 = var.buckfiddy_subnet_name
  resource_group_name  = azurerm_resource_group.buckfiddy.name
  virtual_network_name = azurerm_virtual_network.buckfiddy-vnet.name
  address_prefixes     = [var.buckfiddy_subnet_prefix]
}

module "buckfiddy_nsg" {
  source              = "./modules/nsg"
  resource_group_name = azurerm_resource_group.buckfiddy.name
  location            = azurerm_resource_group.buckfiddy.location
  nsg_name            = "buckfiddy-nsg"  # Define the NSG name here
}

# Attach the NSG to the buckfiddy-subnet
resource "azurerm_subnet_network_security_group_association" "buckfiddy_nsg_association" {
  subnet_id                 = azurerm_subnet.buckfiddy-subnet.id
  network_security_group_id = module.buckfiddy_nsg.id
}

# Setting up storage resources
module "storage" {
  source              = "./modules/storage"
  resource_group_name = azurerm_resource_group.buckfiddy.name
  location            = azurerm_resource_group.buckfiddy.location
}


# Setting up management resources
## Tailscale control server
module "mgmt-vm" {
  source              = "./modules/mgmt-vm"
  resource_group_name = azurerm_resource_group.buckfiddy.name
  location            = azurerm_resource_group.buckfiddy.location
  subnet_id           = azurerm_subnet.buckfiddy-subnet.id
  admin_username      = var.mgmt_vm_admin_username
  admin_password      = var.mgmt_vm_admin_password
  mgmt_containers_blob_url = module.storage.mgmt_containers_blob_url
  mgmt_vm_private_ip  = var.mgmt_vm_private_ip

    depends_on = [
    module.storage
  ]
}

output "mgmt_vm_public_ip" {
  value = module.mgmt-vm.mgmt_vm_public_ip
}

# Setting up app resources
module "app-vm" {
  source              = "./modules/app-vm"
  resource_group_name = azurerm_resource_group.buckfiddy.name
  location            = azurerm_resource_group.buckfiddy.location
  subnet_id           = azurerm_subnet.buckfiddy-subnet.id
  admin_username      = var.app_vm_admin_username
  admin_password      = var.app_vm_admin_password
  app_containers_blob_url = module.storage.app_containers_blob_url
  app_vm_private_ip   = var.app_vm_private_ip

}

# Setting up pentest-operations resources
module "ops-vm-1" {
  source                    = "./modules/ops-vm"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.buckfiddy.name
  subnet_id                 = azurerm_subnet.buckfiddy-subnet.id
  ops_vm_admin_username     = var.ops_vm_admin_username
  ops_vm_admin_password     = var.ops_vm_admin_password
  vm_index                  = 1
  ops_vm_private_ip         = var.ops_vm_1_private_ip

}

module "ops-vm-2" {
  source                    = "./modules/ops-vm"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.buckfiddy.name
  subnet_id                 = azurerm_subnet.buckfiddy-subnet.id
  ops_vm_admin_username     = var.ops_vm_admin_username
  ops_vm_admin_password     = var.ops_vm_admin_password
  vm_index                  = 2
  ops_vm_private_ip         = var.ops_vm_2_private_ip

}

module "ops-vm-3" {
  source                    = "./modules/ops-vm"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.buckfiddy.name
  subnet_id                 = azurerm_subnet.buckfiddy-subnet.id
  ops_vm_admin_username     = var.ops_vm_admin_username
  ops_vm_admin_password     = var.ops_vm_admin_password
  vm_index                  = 3
  ops_vm_private_ip         = var.ops_vm_3_private_ip

}

module "ops-c2-vm" {
  source                    = "./modules/ops-c2-vm"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.buckfiddy.name
  subnet_id                 = azurerm_subnet.buckfiddy-subnet.id
  admin_username            = var.ops_c2_vm_admin_username
  admin_password            = var.ops_c2_vm_admin_password
  vm_index                  = 4
  ops_c2_vm_private_ip      = var.ops_c2_vm_private_ip
  ops_containers_blob_url = module.storage.ops_containers_blob_url

}

# module "redirector_server"

module "forwarder-vm" {
  source                    = "./modules/forwarder-vm"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.buckfiddy.name
  subnet_id                 = azurerm_subnet.buckfiddy-subnet.id
  admin_username            = var.forwarder_vm_admin_username
  admin_password            = var.forwarder_vm_admin_password
  forwarder_vm_private_ip   = var.forwarder_vm_private_ip

}



# Provisioner blocks for mgmt-vm
# another option would be to put three different nics on the C2 servers
# install caddy on the c2 servers to handle nic traffic
# going with this one

# module "redirector_europe"

# module "redirector_useast"


## C2 Command server 1 + 2 (havok and sliver)

## C2 client 1 (havok)

## C2 client 2 (sliver)


