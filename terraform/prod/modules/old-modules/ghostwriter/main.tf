resource "azurerm_public_ip" "ghostwriter" {
  name                = "ghostwriter-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

resource "null_resource" "ghostwriter" {
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = var.vm_admin_username
      password = var.vm_admin_password
      host     = var.vm_public_ip
    }

    inline = [
      "sudo docker run -d --name ghostwriter -p 8000:8000 ghostwriter/ghostwriter:latest"
      # use the local docker-compose files that George wrote up and put it in the root terraform directory 
      # look into terraform provisioners 

      # step 1: reference the /local/directory/docker-compose-files
      # step 2: 
    ]
  }
}