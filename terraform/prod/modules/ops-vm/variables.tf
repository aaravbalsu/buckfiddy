variable "location" {
  description = "The Azure region to deploy resources"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet"
  type        = string
}

variable "ops_vm_admin_username" {
  description = "The admin username for the VM"
  type        = string
}

variable "ops_vm_admin_password" {
  description = "The admin password for the VM"
  type        = string
  sensitive   = true
}

variable "vm_index" {
  description = "The index of the VM"
  type        = number
}

variable "ops_vm_private_ip" {
  type        = string
  description = "The static private IP address for the ops-vm."
}