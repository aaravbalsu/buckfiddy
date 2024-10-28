variable "subscription_id" {
  description = "The subscription ID for Azure"
  type        = string
}

variable "client_id" {
  description = "The client ID (appId) for the service principal"
  type        = string
}

variable "client_secret" {
  description = "The client secret (password) for the service principal"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "The tenant ID for Azure"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region for the resources"
  type        = string
}

# Networking variables

variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
}

variable "vnet_address_space" {
  description = "The address space for the virtual network"
  type        = list(string)
}

variable "buckfiddy_subnet_name" {
  description = "The name of the buckfiddy subnet"
  type        = string
}

variable "buckfiddy_subnet_prefix" {
  description = "The address prefix for the buckfiddy subnet"
  type        = string
}

variable "app_vm_admin_username" {
  description = "Admin username for the App VM."
  type        = string
  default     = "adminuser"
}

variable "app_vm_admin_password" {
  description = "Admin password for the App VM."
  type        = string
  default     = "P@ssw0rd1234"
}

variable "ops_vm_admin_username" {
  description = "Admin username for the Ops VMs."
  type        = string
  default     = "opsadminuser"
}

variable "ops_vm_admin_password" {
  description = "Admin password for the Ops VMs."
  type        = string
  default     = "P@ssw0rd1234"
}

variable "ops_c2_vm_admin_username" {
  description = "Admin username for the Ops VMs."
  type        = string
  default     = "opsadminuser"
}

variable "ops_c2_vm_admin_password" {
  description = "Admin password for the Ops VMs."
  type        = string
  default     = "P@ssw0rd1234"
}

variable "mgmt_vm_admin_username" {
  description = "Admin username for the Ops VMs."
  type        = string
  default     = "opsadminuser"
}

variable "mgmt_vm_admin_password" {
  description = "Admin password for the Ops VMs."
  type        = string
  default     = "P@ssw0rd1234"
}


variable "forwarder_vm_admin_username" {
  description = "The admin username for the forwarder VM"
  type        = string
}

variable "forwarder_vm_admin_password" {
  description = "The admin password for the forwarder VM"
  type        = string
  sensitive   = true
}


variable "mgmt_vm_private_ip" {
  description = "The static private IP address for the management VM"
  type        = string
}


variable "app_vm_private_ip" {
  description = "The static private IP address for the app VM"
  type        = string
}

variable "ops_c2_vm_private_ip" {
  type        = string
  description = "The static private IP address for the ops-c2-vm."
}

variable "ops_vm_1_private_ip" {
  type        = string
  description = "The static private IP address for the first ops-vm."
}

variable "ops_vm_2_private_ip" {
  type        = string
  description = "The static private IP address for the second ops-vm."
}

variable "ops_vm_3_private_ip" {
  type        = string
  description = "The static private IP address for the third ops-vm."
}

variable "forwarder_vm_private_ip" {
  type        = string
  description = "The static private IP address for the forwarder-vm."
}

variable "nsg_name" {
  description = "The name of the Network Security Group."
  type        = string
  default     = "buckfiddy-nsg"  # Optional default if applicable
}