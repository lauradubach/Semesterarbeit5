resource "azurerm_resource_group" "main" {
  name     = "rg-zerotrust-finops-poc"
  location = "switzerlandnorth"
  tags     = local.governance_tags
}

resource "azurerm_storage_account" "func" {
  name                     = "stzerotrustfinopspoc"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  tags                     = local.identity_tags
}

resource "azurerm_service_plan" "func" {
  name                = "asp-zerotrust-finops-poc"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "Y1"
  tags                = local.identity_tags
}

resource "azurerm_linux_function_app" "main" {
  name                        = "func-zerotrust-finops-poc"
  resource_group_name         = azurerm_resource_group.main.name
  location                    = azurerm_resource_group.main.location
  service_plan_id             = azurerm_service_plan.func.id
  storage_account_name        = azurerm_storage_account.func.name
  storage_account_access_key  = azurerm_storage_account.func.primary_access_key

  app_settings = {
    AAD_TENANT_ID = "54bca567-3b11-42be-a7aa-ca09f256cbcc"
    AAD_AUDIENCE  = "api://ba455719-b15a-45d9-83c0-81b98af15722"
  }

  site_config {
    application_stack {
      python_version = "3.11"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.identity_tags
}

output "function_app_principal_id" {
  value = azurerm_linux_function_app.main.identity[0].principal_id
}

output "function_app_default_hostname" {
  value = azurerm_linux_function_app.main.default_hostname
}