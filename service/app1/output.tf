# output about virtual machine
output "vm_ids" {
  description = "The id of the newly created virtual machine"
  value       = module.linuxservers.vm_ids
}

output "vm_public_ip_address" {
  description = "The public ip address of the newly created virtual machine"
  value       = module.linuxservers.public_ip_address
}

output "vm_avset_id" {
  description = "The avset id of the newly created virtual machine"
  value       = module.linuxservers.availability_set_id
}

# output about load balancer
output "lb_id" {
  description = "The id of the newly created load balancer"
  value       = module.loadbalancer.azurerm_lb_id
}

output "lb_ip_address" {
  description = "The ip address of the newly created load balancer"
  value       = module.loadbalancer.azurerm_public_ip_address
}