provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "tf_backend" {
    name = local.resource_group_name
    location = var.location
}

resource "azurerm_storage_account" "tf_backend" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.tf_backend.name
  location                 = azurerm_resource_group.tf_backend.location
  account_tier             = "Standard"
  account_replication_type = "LRS"  
  #allow_blob_public_access = true  // File 테스트용 실배포시 삭제해서 false로 변경
}

resource "azurerm_storage_container" "tf_backend_dev" {
  name                  = "${local.container_name}-dev"
  storage_account_name  = azurerm_storage_account.tf_backend.name
  container_access_type = "container" // 파일 확인용 실 배포시는 private 으로 변경
}

resource "azurerm_storage_container" "tf_backend_stg" {
  name                  = "${local.container_name}-stg"
  storage_account_name  = azurerm_storage_account.tf_backend.name
  container_access_type = "container" // 파일 확인용 실 배포시는 private 으로 변경
}

resource "azurerm_storage_container" "tf_backend_prod" {
  name                  = "${local.container_name}-prod"
  storage_account_name  = azurerm_storage_account.tf_backend.name
  container_access_type = "container" // 파일 확인용 실 배포시는 private 으로 변경
}