provider "azurerm" {
  features {}
}

resource "azurerm_public_ip" "public_ip" {
  name                = "forwarder-vm-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  name                = "forwarder-vm-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.forwarder_vm_private_ip
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "forwarder-vm"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_B1ls"
  delete_os_disk_on_termination = "true"

  storage_os_disk {
    name              = "forwarder-vm-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }


  os_profile {
    computer_name  = "forwarder-vm"
    admin_username = var.admin_username
    admin_password = var.admin_password

    custom_data    = <<-EOF
      #cloud-config
      package_update: true
      packages:
        - socat
        - screen
        - curl
      runcmd:
        - screen -dmS win_https-msf_handler socat TCP4-LISTEN:443,fork TCP4:10.150.1.6:8443
        - screen -dmS win_tcp-msf_handler socat TCP4-LISTEN:4444,fork TCP4:10.150.1.6:4444
        - screen -dmS linux-x86_tcp-msf_handler socat TCP4-LISTEN:6444,fork TCP4:10.150.1.6:6444
        - screen -dmS linux-x64_tcp-msf_handler socat TCP4-LISTEN:8444,fork TCP4:10.150.1.6:8444
        #- curl -fsSL https://tailscale.com/install.sh | sh && sudo tailscale up --login-server http://10.150.1.4 --authkey c91b772550d13dba07cd6a111c69c54cd70cb870bb902374 --hostname=redirect &
    EOF
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "dev"
  }
}