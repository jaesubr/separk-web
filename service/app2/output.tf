# output about kubernetes cluster
output "aks_id" {
  description = "The id of the newly created kubernetes cluster"
  value       = module.aks.aks_id
}

output "aks_node_rg" {
  description = "The resource group of the newly created kubernetes cluster work node"
  value       = module.aks.node_resource_group
}
