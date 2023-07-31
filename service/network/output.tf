# output about resource group
output "resource_group_name" {
  description = "The name of the newly created resource group"
  value       = azurerm_resource_group.rg.name
}

# output about virtual network
output "vnet_name" {
  description = "The name of the newly created vNet"
  value       = module.network.vnet_name
}

output "vnet_address_space" {
  description = "The address space of the newly created vNet"
  value       = module.network.vnet_address_space
}

output "vnet_subnets" {
  description = "The ids of subnets created inside the newly created vNet"
  value       = module.network.vnet_subnets
}
