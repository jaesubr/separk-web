variable "resource_group_name" {
  description = "The name of an existing resource group to be imported"
  type        = string
}

variable "vnet_subnet_id" {
  description = "The subnet id of the virtual network where the virtual machines will reside."
  type        = string
}

## About VM Instatnce
variable "vm_hostname" {
  description = "local name of the Virtual Machine."
  type        = string
  default     = "ski-iac-vm"
}

variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "number_instances" {
  description = "Specify the number of vm instances."
  type        = number
  default     = 1
}

variable "vm_os_defined" {
  description = "Specify UbuntuServer, WindowsServer, RHEL, openSUSE-Leap, CentOS, Debian, CoreOS and SLES to get the latest image version of the specified os. "
  type        = string
  default     = ""
}

variable "vm_os_custom" {
  description = "The resource ID of the image that you want to deploy if you are using a custom image.Note, need to provide is_windows_image = true for windows custom images."
  type        = string
  default     = ""
}

variable "vm_os_publisher" {
  description = "The name of the publisher of the image that you want to deploy. This is ignored when vm_os_id or vm_os_defined are provided."
  type        = string
  default     = ""
}

variable "vm_os_offer" {
  description = "The name of the offer of the image that you want to deploy. This is ignored when vm_os_id or vm_os_defined are provided."
  type        = string
  default     = ""
}

variable "vm_os_sku" {
  description = "The sku of the image that you want to deploy. This is ignored when vm_os_id or vm_os_defined are provided."
  type        = string
  default     = ""
}

variable "vm_os_version" {
  description = "The version of the image that you want to deploy. This is ignored when vm_os_id or vm_os_defined are provided."
  type        = string
  default     = "latest"
}

variable "is_windows_image" {
  description = "Boolean flag to notify when the custom image is windows based."
  type        = bool
  default     = false
}


## About Disk
variable "storage_account_type" {
  description = "Defines the type of storage account to be created. Valid options are Standard_LRS, Standard_ZRS, Standard_GRS, Standard_RAGRS, Premium_LRS."
  type        = string
  default     = "Premium_LRS"
}

variable "data_sa_type" {
  description = "Data Disk Storage Account type."
  type        = string
  default     = "Standard_LRS"
}

variable "data_disk_size_gb" {
  description = "Storage data disk size size."
  type        = number
  default     = 30
}

variable "number_data_disk" {
  description = "(Optional) Number of the data disks attached to each virtual machine."
  type        = number
  default     = 0
}

variable "delete_os_disk_on_termination" {
  type        = bool
  description = "Delete datadisk when machine is terminated."
  default     = false
}

variable "delete_data_disks_on_termination" {
  type        = bool
  description = "Delete data disks when machine is terminated."
  default     = false
}


# About Network
variable "allocation_method" {
  description = "Defines how an IP address is assigned. Options are Static or Dynamic."
  type        = string
  default     = "Dynamic"
}

variable "public_ip_sku" {
  description = "Defines the SKU of the Public IP. Accepted values are Basic and Standard. Defaults to Basic."
  type        = string
  default     = "Basic"
}

variable "number_public_ip" {
  description = "Number of public IPs to assign corresponding to one IP per vm. Set to 0 to not assign any public IP addresses."
  type        = number
  default     = 1
}

variable "remote_port" {
  description = "Remote tcp port to be used for access to the vms created via the nsg applied to the nics."
  type        = string
  default     = ""
}

variable "source_address_prefixes" {
  description = "(Optional) List of source address prefixes allowed to access var.remote_port."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# About Secret

variable "enable_ssh_key" {
  type        = bool
  description = "(Optional) Enable ssh key authentication in Linux virtual Machine."
  default     = true
}

variable "ssh_key" {
  description = "Path to the public key to be used for ssh access to the VM. e.g. c:/home/id_rsa.pub."
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_key_values" {
  description = "List of Public SSH Keys values to be used for ssh access to the VMs."
  type        = list(string)
  default     = []
}

variable "admin_username" {
  description = "The admin username of the VM that will be deployed."
  type        = string
  default     = "iacuser"
}

variable "admin_password" {
  description = "The admin password to be used on the VMSS that will be deployed. The password must meet the complexity requirements of Azure."
  type        = string
  default     = ""
}

# BYOL 
variable "license_type" {
  description = "Specifies the BYOL Type for this Virtual Machine. This is only applicable to Windows Virtual Machines. Possible values are Windows_Client and Windows_Server"
  type        = string
  default     = null
}

# Cloud-Init Script
variable "custom_data" {
  description = "The custom data to supply to the machine. This can be used as a cloud-init for Linux systems."
  type        = string
  default     = ""
}


variable "tags" {
  type        = map(string)
  description = "A map of the tags to use on the resources that are deployed"

  default = {
    environment = "dev"
  }
}
