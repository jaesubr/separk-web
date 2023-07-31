variable "resource_group_name" {
  description = "The name of an existing resource group to be imported."
  type        = string
}

variable "security_group_name" {
  description = "Name of the nsg to create."
  type        = string
  default     = "nsg"
}

# Security Rules definition 

# Predefined rules   
variable "predefined_rules" {
  type    = any
  default = []
}

# Custom security rules
# [priority, direction, access, protocol, source_port_range, destination_port_range, description]"
# All the fields are required.
variable "custom_rules" {
  description = "Security rules for the network security group using this format name = [priority, direction, access, protocol, source_port_range, destination_port_range, source_address_prefix, destination_address_prefix, description]"
  type        = any
  default     = []
}

# source address prefix to be applied to all predefined rules
# list(string) only allowed one element (CIDR, `*`, source IP range or Tags)
# Example ["10.0.3.0/24"] or ["VirtualNetwork"]
variable "source_address_prefix" {
  type    = list(string)
  default = ["*"]
}

# Destination address prefix to be applied to all predefined rules
# Example ["10.0.3.0/32","10.0.3.128/32"]
variable "source_address_prefixes" {
  type    = list(string)
  default = null
}

# Destination address prefix to be applied to all predefined rules
# list(string) only allowed one element (CIDR, `*`, source IP range or Tags)
# Example ["10.0.3.0/24"] or ["VirtualNetwork"]
variable "destination_address_prefix" {
  type    = list(string)
  default = ["*"]
}

# Destination address prefix to be applied to all predefined rules
# Example ["10.0.3.0/32","10.0.3.128/32"]
variable "destination_address_prefixes" {
  type    = list(string)
  default = null
}

variable "tags" {
  description = "The tags to associate with your network security group"
  type        = map(string)
}