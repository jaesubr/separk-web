# Import Data type resource

data "azurerm_resource_group" "rg" {
  name = local.resource_group_name
}

data "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  resource_group_name = local.resource_group_name
}

data "azurerm_subnet" "subnet1" {
  name                 = "${local.subnet_prefix}-app1-subnet"
  virtual_network_name = local.vnet_name
  resource_group_name  = local.resource_group_name
}

data "azurerm_subnet" "subnet2" {
  name                 = "${local.subnet_prefix}-app2-subnet"
  virtual_network_name = local.vnet_name
  resource_group_name  = local.resource_group_name
}

data "azurerm_subnet" "subnet3" {
  name                 = "${local.subnet_prefix}-app3-subnet"
  virtual_network_name = local.vnet_name
  resource_group_name  = local.resource_group_name
}


# Create Kubernetes Cluster

module "aks" {
  source                           = "../../modules/kubernetes_cluster"
  resource_group_name              = data.azurerm_resource_group.rg.name
  prefix                           = "ski-iac-demo"
  cluster_name                     = "${var.project_name}-${var.env}-aks"
  network_plugin                   = "azure"
  vnet_subnet_id                   = data.azurerm_subnet.subnet2.id
  os_disk_size_gb                  = var.os_disk_size
  agents_min_count                 = var.min_count
  agents_max_count                 = var.max_count
  agents_max_pods                  = var.max_pods
  agents_pool_name                 = "nodepool"
  ssh_key                          = "../id_rsa.pub"


  enable_ingress_application_gateway = true
  ingress_application_gateway_name = "${var.project_name}-${var.env}-app1-agw"
  ingress_application_gateway_subnet_cidr = "10.10.11.0/24"

  tags                = var.tags

}