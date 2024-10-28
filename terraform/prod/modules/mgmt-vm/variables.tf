variable "resource_group_name" {
  type        = string
  description = "The name of the resource group."
}

variable "location" {
  type        = string
  description = "The Azure location where resources will be created."
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet where the VM will be deployed."
}

variable "admin_username" {
  type        = string
  description = "The admin username for the VM."
}

variable "admin_password" {
  type        = string
  description = "The admin password for the VM."
}

variable "mgmt_containers_blob_url" {
  description = "The URL of the management containers blob."
  type        = string
}

variable "mgmt_vm_private_ip" {
  type        = string
  description = "The static private IP address for the mgmt-vm."
}