provider "azurerm" {
  features {}
}

resource "azurerm_public_ip" "ops_c2_vm" {
  name                = "ops-c2-vm-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "ops_c2_vm_nic" {
  name                = "ops-c2-vm-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    private_ip_address_allocation = "Static"
    private_ip_address            = var.ops_c2_vm_private_ip
    public_ip_address_id          = azurerm_public_ip.ops_c2_vm.id
    subnet_id                     = var.subnet_id
  }
}

resource "azurerm_virtual_machine" "ops_c2_vm" {
  name                  = "ops-c2-vm"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.ops_c2_vm_nic.id]
  vm_size               = "Standard_B2s"
  delete_os_disk_on_termination = "true"

  os_profile {
    computer_name  = "ops-c2-vm"
    admin_username = var.admin_username
    admin_password = var.admin_password
    custom_data    = <<-EOF
      #cloud-config
      package_update: true
      packages:
        - apt-transport-https
        - ca-certificates
        - curl
        - software-properties-common
        - unzip
      runcmd:
        - echo "Updating sources..."
        - sudo apt update
        - curl https://sliver.sh/install | sudo bash &
        - echo "Installing required packages..."
        - sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
        - sudo apt remove -y docker docker-engine docker.io containerd runc
        - echo "Adding GPG keys for Docker source repository..."
        - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker-archive-keyring.gpg
        - echo "Adding Docker source repository..."
        - yes | sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        - echo "Updating sources to include Docker repository..."
        - sudo apt update
        - echo "Installing Docker..."
        - sudo apt install -y docker-ce docker-ce-cli containerd.io
        - sudo systemctl enable docker
        - sudo systemctl start docker
        - newgrp docker
        - sudo usermod -aG docker ${var.admin_username}
        - echo "Downloading and installing Docker Compose..."
        - sudo curl -s https://api.github.com/repos/docker/compose/releases/latest | grep browser_download_url | grep docker-compose-linux-x86_64 | cut -d '"' -f 4 | wget -qi - -O /usr/local/bin/docker-compose
        - sudo chmod +x /usr/local/bin/docker-compose
        - sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
        - echo "Downloading and extracting ops_containers.zip"
        - wget ${var.ops_containers_blob_url} -O /home/${var.admin_username}/ops_containers.zip
        - unzip -o /home/${var.admin_username}/ops_containers.zip -d /home/${var.admin_username}/
        - find /home/${var.admin_username}/ops_containers -mindepth 1 -maxdepth 1 -exec mv -t /home/${var.admin_username}/ {} +
        - rm -rf /home/${var.admin_username}/ops_containers
        - rm /home/${var.admin_username}/ops_containers.zip
        - cd /home/${var.admin_username}
        - /bin/bash -c "sleep 180 && curl -fsSL https://tailscale.com/install.sh | sh && sudo tailscale up --login-server http://10.150.1.4 --authkey 977496174ba9531c9bf27228091d612e6e272bee39ca481d --hostname=ops" &
        - docker network create ops-net
        - docker-compose up -d
    EOF
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  storage_os_disk {
    name              = "ops-c2-vm-osdisk"
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

}