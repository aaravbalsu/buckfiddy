provider "azurerm" {
  features {}
}

resource "azurerm_public_ip" "ops_vm" {
  name                = "ops-vm-public-ip-${var.vm_index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "ops_vm_nic" {
  name                = "ops-vm-nic-${var.vm_index}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.ops_vm_private_ip
    public_ip_address_id          = azurerm_public_ip.ops_vm.id
  }
}

resource "azurerm_virtual_machine" "ops_vm" {
  name                  = "ops-vm-${var.vm_index}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.ops_vm_nic.id]
  vm_size               = "Standard_B1s"
  delete_os_disk_on_termination = "true"

  os_profile {
    computer_name  = "ops-vm-${var.vm_index}"
    admin_username = var.ops_vm_admin_username
    admin_password = var.ops_vm_admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  storage_os_disk {
    name              = "ops-vm-osdisk-${var.vm_index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "kali-linux"
    offer     = "kali"
    sku       = "kali-2023-4"
    version   = "2023.4.0"
  }
  plan {
    name      = "kali-2023-4" #make sure you accept the legal terms by running "az vm image terms accept --publisher kali-linux --offer kali --plan kali-2023-4"
    product   = "kali"
    publisher = "kali-linux"
  }
}