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

# Create Virtual Machine 

module "linuxservers" {
  source              = "../../modules/virtual_machine"
  number_instances    = var.vm_count
  resource_group_name = data.azurerm_resource_group.rg.name
  vm_hostname         = "${var.project_name}-${var.env}-iac"
  vm_os_defined       = var.vm_os
  vm_size             = var.vm_type
  vnet_subnet_id      = data.azurerm_subnet.subnet1.id
  remote_port         = "22"
  ssh_key             = "../id_rsa.pub"

  tags                = var.tags

}

# Create Load Balancer

module "loadbalancer" {
  source              = "../../modules/load_balancer"
  resource_group_name = data.azurerm_resource_group.rg.name
  name                = "${var.project_name}-${var.env}-app1-lb-001"
  pip_name            = "${var.project_name}-${var.env}-app1-lb-pip-001"

  remote_port = {
    ssh = ["Tcp", "22"]
  }

  lb_port = {
    http = ["80", "Tcp", "80"]
  }

  lb_probe = {
    http = ["Tcp", "80", ""]
  }

  tags                = var.tags
}



## Demo Scenario #1 (Add Window VM // module "windowsservers" {} 전체 주석 제거 후 배포)
/*
module "windowsservers" {
  source              = "../../modules/virtual_machine"
  resource_group_name = data.azurerm_resource_group.rg.name
  is_windows_image    = true
  vm_hostname         = "iac" 
  admin_password      = "Cloud2022!#%&"
  vm_os_defined       = var.vm_os_demo
  vnet_subnet_id      = data.azurerm_subnet.subnet1.id
  remote_port         = "3389"

  tags                = var.tags 

  // Demo Scenario #2 (Edit Window VM Type // 하단 라인 주석 제거 후 배포)
  vm_size             = var.vm_type_demo

}
*/
## Demo Scenario #3 (Delete Window VM // module "windowsservers" {} 전체 주석 처리 후 배포)