resource "azurerm_public_ip" "gitea" {
  name                = "gitea-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

resource "null_resource" "gitea" {
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = var.vm_admin_username
      password = var.vm_admin_password
      host     = var.vm_public_ip
    }

    inline = [
      "sudo docker run -d --name gitea -p 3000:3000 gitea/gitea:latest"

      # step 1, reference the YAML file
      # step 2, parse the whole raw YAML file 
      # step 3, implement that logic into the container that's getting spun up on the VM
      # step 4, bring VM online
    ]
  }
}