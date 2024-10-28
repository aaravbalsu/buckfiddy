resource "azurerm_public_ip" "privatebin" {
  name                = "privatebin-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

resource "null_resource" "privatebin" {
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = var.vm_admin_username
      password = var.vm_admin_password
      host     = var.vm_public_ip
    }

    inline = [
      "sudo docker run -d --name privatebin -p 8080:80 privatebin/nginx-fpm-alpine:latest"
    ]
  }
}