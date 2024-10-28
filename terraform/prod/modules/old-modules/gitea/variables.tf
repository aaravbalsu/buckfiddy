variable "vm_admin_username" {
  type        = string
  description = "The admin username for the VM where Gitea will be deployed."
}

variable "vm_admin_password" {
  type        = string
  description = "The admin password for the VM where Gitea will be deployed."
}

variable "vm_public_ip" {
  type        = string
  description = "The public IP address of the VM where Gitea will be deployed."
}

variable "location" {
  type        = string
  description = "The Azure location where resources will be created."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group."
}