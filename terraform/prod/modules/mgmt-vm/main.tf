# Uncomment when dealing with issues during login to Keycloak portal; "Cookies not found..."
#- KC_PWD=”if_you-raise_the-price_ill_KILL-YOU”
#- docker exec -it keycloak bash -c "/opt/keycloak/bin/kcadm.sh update realms/master -s sslRequired=NONE --server http://l33t.buckfiddy/auth --realm master --user b50admin --password \"$KC_PWD\""
#- docker exec -it keycloak bash -c "/opt/keycloak/bin/kcadm.sh update realms/buckfiddy -s sslRequired=NONE --server http://l33t.buckfiddy/auth --realm master --user b50admin --password \"$KC_PWD\""

resource "azurerm_public_ip" "mgmt_vm_public_ip" {
  name                = "mgmt-vm-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  name                = "mgmt-vm-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.mgmt_vm_private_ip
    public_ip_address_id          = azurerm_public_ip.mgmt_vm_public_ip.id
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "mgmt-vm"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_B2s"
  delete_os_disk_on_termination = "true"

  storage_os_disk {
    name              = "mgmt-vm-osdisk"
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
    computer_name  = "mgmt-vm"
    admin_username = var.admin_username
    admin_password = var.admin_password
    # wanted to source the following YAML logic from a different file that's hosted locally, but we were running into issues where it wasn't getting parsed properly by the cloud-init.py script on the VM once it spun up. 
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
        - echo "Downloading and extracting mgmt_containers.zip"
        - wget ${var.mgmt_containers_blob_url} -O /home/${var.admin_username}/mgmt_containers.zip
        - unzip -o /home/${var.admin_username}/mgmt_containers.zip -d /home/${var.admin_username}/
        - find /home/${var.admin_username}/mgmt_containers -mindepth 1 -maxdepth 1 -exec mv -t /home/${var.admin_username}/ {} +
        - rm -rf /home/${var.admin_username}/mgmt_containers
        - rm /home/${var.admin_username}/mgmt_containers.zip
        - docker network create kc-net
        - docker network create mgt-net
        - sleep 20
        - sudo chown -R 1000 headscale/ui/volume/
        - cd /home/${var.admin_username}
        - sudo chown -R 1000:1000 /home/${var.admin_username}/headscale/ui/volume
        - echo -e '# Allow a 25MB UDP receive buffer for JGroups \nnet.core.rmem_max = 26214400 \n# Allow a 1MB UDP send buffer for JGroups \nnet.core.wmem_max = 1048576 \n' | sudo tee -a /etc/sysctl.conf && sysctl -p
        - docker-compose up -d
        - sleep 30
        - curl -fsSL https://tailscale.com/install.sh | sh && sudo tailscale up --login-server http://10.150.1.4 --authkey 1b569386d06907e555cfaba1f7dcbfcbed81b0b7d23a8283 --hostname=mgt
    EOF
  }
  
  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "dev"
  }
}

output "mgmt_vm_public_ip" {
  value = azurerm_public_ip.mgmt_vm_public_ip.ip_address
}