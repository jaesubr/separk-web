#############################################################################

variable "location" {}
variable "project_name" {}
variable "env" {}

#############################################################################
variable "os_disk_size" {}
variable "max_pods" {}
variable "min_count" {}
variable "max_count" {}

#############################################################################
variable "tags" {} 

#############################################################################
variable "region_list" {
  type        = map(string)
  
  default     = {
    eastasia            = "asea",
    southeastasia       = "assw",
    centralus           = "usce",
    eastus              = "usea",
    eastus2             = "use2",
    westus              = "uswe",
    westus2             = "usw2",
    northcentralus      = "usnc",
    southcentralus      = "ussc",
    westcentralus       = "uswc",
    northeurope         = "euno",
    westeurop           = "euwe",
    japanwest           = "jawe",
    japaneast           = "jaea",
    brazilsouth         = "brso",
    australiaeast       = "auea",
    australiasoutheast  = "ause",
    southindia          = "inso",
    centralindia        = "ince",
    westindia           = "inwe",
    canadacentral       = "cace",
    canadaeast          = "caea",
    uksouth             = "ukso",
    ukwest              = "ukwe",
    koreacentral        = "koce",
    koreasouth          = "koso",
    francecentral       = "frce",
    francesouth         = "frso",
    australiacentral    = "auce",
    australiacentral2   = "auc2",
    southafricanorth    = "sano",
    southafricawest     = "sawe"
  }
}

# Apply Naming Rule, Tagging Rule
locals {
  resource_group_name = "${var.project_name}-${var.env}-rg"
  vnet_name = "${var.project_name}-${var.env}-${lookup(var.region_list, var.location, "koce")}-vnet"
  subnet_prefix = "${var.project_name}-${var.env}-${lookup(var.region_list, var.location, "koce")}"
}