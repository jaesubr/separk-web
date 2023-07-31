provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    key = "ski-iac-demo.terraform-app2.tfstate"
  }
}