resource "azurerm_public_ip" "public_ip" {
  name                = "vm-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  name                = "vm-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    private_ip_address_allocation = "Static"
    private_ip_address            = var.app_vm_private_ip
    public_ip_address_id          = azurerm_public_ip.public_ip.id
    subnet_id                     = var.subnet_id    
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "app-vm"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_B2s"
  delete_os_disk_on_termination = "true"

  storage_os_disk {
    name              = "app-vm-osdisk"
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
    computer_name  = "app-vm"
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
        - echo "Downloading and extracting app_containers.zip"
        - wget ${var.app_containers_blob_url} -O /home/${var.admin_username}/app_containers.zip
        - unzip -o /home/${var.admin_username}/app_containers.zip -d /home/${var.admin_username}/
        - find /home/${var.admin_username}/app_containers -mindepth 1 -maxdepth 1 -exec mv -t /home/${var.admin_username}/ {} +
        - rm -rf /home/${var.admin_username}/app_containers
        - rm /home/${var.admin_username}/app_containers.zip
        - docker network create port-net
        - docker network create app-net
        - docker network create db-net
        - cd /home/${var.admin_username}
        - docker-compose up -d
        - sleep 60
        - curl -fsSL https://tailscale.com/install.sh | sh && sudo tailscale up --login-server http://10.150.1.4 --authkey 1785b619f62b259a57f0908687bda5f45cc2c519a0fb5500 --hostname=app &
        - git clone https://github.com/GhostManager/Ghostwriter.git
        - cd Ghostwriter
        - ./ghostwriter-cli-linux install
        - ./ghostwriter-cli-linux containers down
        - ./ghostwriter-cli-linux config allowhost report.buckfiddy
        - ./ghostwriter-cli-linux config allowhost team.buckfiddy
        - ./ghostwriter-cli-linux containers up
    EOF 
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "dev"
  }
}