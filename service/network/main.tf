# Create resource group
resource "azurerm_resource_group" "rg" {
  name = local.resource_group_name
  location = var.location
}

# Create network
module "network" {
  source              = "../../modules/vnet"
  vnet_name           = local.vnet_name
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.cidr
  subnet_prefixes     = [var.subnet1, var.subnet2, var.subnet3]
  subnet_names        = ["${local.subnet_prefix}-app1-subnet", "${local.subnet_prefix}-app2-subnet", "${local.subnet_prefix}-app3-subnet"]

  tags                = var.tags

  depends_on          = [azurerm_resource_group.rg]
}

# Create Network Security Group
module "network-security-group" {
  source                = "../../modules/network_security_group"
  resource_group_name   = azurerm_resource_group.rg.name
  security_group_name   = "${local.subnet_prefix}-app1-subnet-nsg"
  source_address_prefix = ["10.0.3.0/24"] ## IP 예시
  
  #predefined_rules = [
   # {
    #  name                   = "SSH" 
     # priority               = "300"
    #},
    #{
      #name                   = "FTP"
    #}
  #]

  custom_rules = [
    {
      name                   = "Service" 
      priority               = 201
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "Tcp"
      source_port_range      = "*"
      destination_port_range = "8080"
      description            = "application service port"
    },
    {
      name                    = "Admin"
      priority                = 200
      direction               = "Inbound"
      access                  = "Allow"
      protocol                = "Tcp"
      source_port_range       = "*"
      destination_port_range  = "9879"
      source_address_prefixes = ["10.0.3.0/24", "10.0.4.0/24"]
      description             = "admin portal port"
    },
  ]

  tags                = var.tags

  depends_on          = [azurerm_resource_group.rg, module.network]
}