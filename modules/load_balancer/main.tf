# Azure load balancer module
data "azurerm_resource_group" "lb" {
  name = var.resource_group_name
}

locals {
  lb_name  = var.name != "" ? var.name : format("%s-lb", var.prefix)
  pip_name = var.pip_name != "" ? var.pip_name : format("%s-pip", var.prefix)
}

resource "azurerm_public_ip" "lb_pip" {
  count               = var.type == "public" ? 1 : 0
  name                = local.pip_name
  resource_group_name = data.azurerm_resource_group.lb.name
  location            = data.azurerm_resource_group.lb.location
  allocation_method   = var.allocation_method
  sku                 = var.pip_sku
  tags                = var.tags
}

resource "azurerm_lb" "lb" {
  name                = local.lb_name
  resource_group_name = data.azurerm_resource_group.lb.name
  location            = data.azurerm_resource_group.lb.location
  sku                 = var.lb_sku
  tags                = var.tags

  frontend_ip_configuration {
    name                          = var.frontend_name
    public_ip_address_id          = var.type == "public" ? join("", azurerm_public_ip.lb_pip.*.id) : ""
    subnet_id                     = var.frontend_subnet_id
    private_ip_address            = var.frontend_private_ip_address
    private_ip_address_allocation = var.frontend_private_ip_address_allocation
  }
}

resource "azurerm_lb_backend_address_pool" "lb_backend" {
  name                = "BackEndAddrPool"
  loadbalancer_id     = azurerm_lb.lb.id
}

resource "azurerm_lb_nat_rule" "lb_nat_rule" {
  count                          = length(var.remote_port)
  name                           = "Nat-Rule-${count.index}"
  resource_group_name            = data.azurerm_resource_group.lb.name
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "Tcp"
  frontend_port                  = "5000${count.index + 1}"
  backend_port                   = element(var.remote_port[element(keys(var.remote_port), count.index)], 1)
  frontend_ip_configuration_name = var.frontend_name
}

resource "azurerm_lb_probe" "lb_probe" {
  count               = length(var.lb_probe)
  name                = element(keys(var.lb_probe), count.index)
  #resource_group_name = data.azurerm_resource_group.lb.name
  loadbalancer_id     = azurerm_lb.lb.id
  protocol            = element(var.lb_probe[element(keys(var.lb_probe), count.index)], 0)
  port                = element(var.lb_probe[element(keys(var.lb_probe), count.index)], 1)
  interval_in_seconds = var.lb_probe_interval
  number_of_probes    = var.lb_probe_unhealthy_threshold
  request_path        = element(var.lb_probe[element(keys(var.lb_probe), count.index)], 2)
}

resource "azurerm_lb_rule" "lb_rule" {
  count                          = length(var.lb_port)
  name                           = element(keys(var.lb_port), count.index)
  #resource_group_name            = data.azurerm_resource_group.lb.name
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = element(var.lb_port[element(keys(var.lb_port), count.index)], 1)
  frontend_port                  = element(var.lb_port[element(keys(var.lb_port), count.index)], 0)
  backend_port                   = element(var.lb_port[element(keys(var.lb_port), count.index)], 2)
  frontend_ip_configuration_name = var.frontend_name
  enable_floating_ip             = false
  #backend_address_pool_id        = azurerm_lb_backend_address_pool.lb_backend.id 
  idle_timeout_in_minutes        = 5
  probe_id                       = element(azurerm_lb_probe.lb_probe.*.id, count.index)
}