#############################################################################
# These values are placeholders. You should set and use the values of '../project.tfvars'
variable "location" {}
variable "project_name" {}
#############################################################################

locals {
    resource_group_name = "${var.project_name}-tf-backend-rg"
    storage_account_name = format("%stfbackend01",replace(var.project_name, "-", ""))
    container_name        = "${replace(var.project_name, "-", "")}tfcontainer"
}
