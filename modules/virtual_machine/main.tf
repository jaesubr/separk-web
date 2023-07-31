module "os" {
  source       = "./os"
  vm_os_defined = var.vm_os_defined
}

data "azurerm_resource_group" "vm" {
  name = var.resource_group_name
}

locals {
  ssh_keys = compact([var.ssh_key])
}

resource "azurerm_virtual_machine" "vm-linux" {
  count                            = ! contains(tolist([var.vm_os_defined]), "WindowsServer") && ! var.is_windows_image ? var.number_instances : 0
  name                             = "${var.vm_hostname}-${count.index}"
  resource_group_name              = data.azurerm_resource_group.vm.name
  location                         = data.azurerm_resource_group.vm.location
  availability_set_id              = azurerm_availability_set.vm.id
  vm_size                          = var.vm_size
  network_interface_ids            = [element(azurerm_network_interface.vm.*.id, count.index)]
  delete_os_disk_on_termination    = var.delete_os_disk_on_termination
  delete_data_disks_on_termination = var.delete_data_disks_on_termination

## custom image part, only base code
  storage_image_reference {
    id        = var.vm_os_custom
    publisher = var.vm_os_custom == "" ? coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher) : ""
    offer     = var.vm_os_custom == "" ? coalesce(var.vm_os_offer, module.os.calculated_value_os_offer) : ""
    sku       = var.vm_os_custom == "" ? coalesce(var.vm_os_sku, module.os.calculated_value_os_sku) : ""
    version   = var.vm_os_custom == "" ? var.vm_os_version : ""
  }

  storage_os_disk {
    name              = "${var.vm_hostname}-disk-${count.index}" 
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = var.storage_account_type
  }

  dynamic storage_data_disk {
    for_each = range(var.number_data_disk)
    content {
      name              = "${var.vm_hostname}-datadisk-${count.index}-${storage_data_disk.value}"
      create_option     = "Empty"
      lun               = storage_data_disk.value
      disk_size_gb      = var.data_disk_size_gb
      managed_disk_type = var.data_sa_type
    }
  }

  os_profile {
    computer_name  = "${var.vm_hostname}-${count.index}"
    admin_username = var.admin_username
    admin_password = var.admin_password
    custom_data    = var.custom_data
  }

  os_profile_linux_config {
    disable_password_authentication = var.enable_ssh_key

    dynamic ssh_keys {
      for_each = var.enable_ssh_key ? local.ssh_keys : []
      content {
        path     = "/home/${var.admin_username}/.ssh/authorized_keys"
        key_data = file(ssh_keys.value)
      }
    }

  }

  tags = var.tags

}

resource "azurerm_virtual_machine" "vm-windows" {
  count                         = (var.is_windows_image || contains(tolist([var.vm_os_defined, var.vm_os_offer]), "WindowsServer")) ? var.number_instances : 0
  name                          = "${var.vm_hostname}-${count.index}"
  resource_group_name           = data.azurerm_resource_group.vm.name
  location                      = data.azurerm_resource_group.vm.location
  availability_set_id           = azurerm_availability_set.vm.id
  vm_size                       = var.vm_size
  network_interface_ids         = [element(azurerm_network_interface.vm.*.id, count.index)]
  delete_os_disk_on_termination = var.delete_os_disk_on_termination
  license_type                  = var.license_type


  storage_image_reference {
    id        = var.vm_os_custom
    publisher = var.vm_os_custom == "" ? coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher) : ""
    offer     = var.vm_os_custom == "" ? coalesce(var.vm_os_offer, module.os.calculated_value_os_offer) : ""
    sku       = var.vm_os_custom == "" ? coalesce(var.vm_os_sku, module.os.calculated_value_os_sku) : ""
    version   = var.vm_os_custom == "" ? var.vm_os_version : ""
  }

  storage_os_disk {
    name              = "${var.vm_hostname}-disk-${count.index}"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = var.storage_account_type
  }

  dynamic storage_data_disk {
    for_each = range(var.number_data_disk)
    content {
      name              = "${var.vm_hostname}-datadisk-${count.index}-${storage_data_disk.value}"
      create_option     = "Empty"
      lun               = storage_data_disk.value
      disk_size_gb      = var.data_disk_size_gb
      managed_disk_type = var.data_sa_type
    }
  }

  os_profile {
    computer_name  = "${var.vm_hostname}-${count.index}"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  tags = var.tags

  # Azure 가상머신 Agent가 필요?
  os_profile_windows_config {
    provision_vm_agent = true
  }

}

#AVset 요구사항 반영
resource "azurerm_availability_set" "vm" {
  name                         = "${var.vm_hostname}-avs"
  resource_group_name          = data.azurerm_resource_group.vm.name
  location                     = data.azurerm_resource_group.vm.location
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
  tags                         = var.tags
}

resource "azurerm_public_ip" "vm" {
  count               = var.number_public_ip
  name                = "${var.vm_hostname}-pip-${count.index}"
  resource_group_name = data.azurerm_resource_group.vm.name
  location            = data.azurerm_resource_group.vm.location
  allocation_method   = var.allocation_method
  sku                 = var.public_ip_sku
  tags                = var.tags
}

// Dynamic public ip address will be got after it's assigned to a vm
data "azurerm_public_ip" "vm" {
  count               = var.number_public_ip
  name                = azurerm_public_ip.vm[count.index].name
  resource_group_name = data.azurerm_resource_group.vm.name
  depends_on          = [azurerm_virtual_machine.vm-linux, azurerm_virtual_machine.vm-windows]
}

## Modification or deletion according to the rules of operation
resource "azurerm_network_security_group" "vm" {
  name                = "${var.vm_hostname}-nsg"
  resource_group_name = data.azurerm_resource_group.vm.name
  location            = data.azurerm_resource_group.vm.location

  tags = var.tags
}

## Modification or deletion according to the rules of operation
resource "azurerm_network_security_rule" "vm" {
  count                       = var.remote_port != "" ? 1 : 0
  name                        = "allow_remote_${coalesce(var.remote_port, module.os.calculated_remote_port)}_in_all"
  resource_group_name         = data.azurerm_resource_group.vm.name
  description                 = "Allow remote protocol in from all locations"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = coalesce(var.remote_port, module.os.calculated_remote_port)
  source_address_prefixes     = var.source_address_prefixes
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.vm.name
}

resource "azurerm_network_interface" "vm" {
  count                         = var.number_instances
  name                          = "${var.vm_hostname}-nic-${count.index}"
  resource_group_name           = data.azurerm_resource_group.vm.name
  location                      = data.azurerm_resource_group.vm.location

  ip_configuration {
    name                          = "${var.vm_hostname}-ip-${count.index}"
    subnet_id                     = var.vnet_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = length(azurerm_public_ip.vm.*.id) > 0 ? element(concat(azurerm_public_ip.vm.*.id, tolist([""])), count.index) : ""
  }

  tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "SG" {
  count                     = var.number_instances
  network_interface_id      = azurerm_network_interface.vm[count.index].id
  network_security_group_id = azurerm_network_security_group.vm.id
}