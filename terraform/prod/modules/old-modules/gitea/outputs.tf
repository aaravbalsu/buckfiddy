output "gitea_public_ip" {
  description = "The public IP address of the Gitea VM"
  value       = azurerm_public_ip.gitea.ip_address
}