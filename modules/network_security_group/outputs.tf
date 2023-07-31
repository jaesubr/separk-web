output "network_security_group_id" {
  description = "The id of the newly created Security Group"
  value       = azurerm_network_security_group.nsg.id
}

output "network_security_group_name" {
  description = "The name of the newly created Security Group"
  value       = azurerm_network_security_group.nsg.name
}