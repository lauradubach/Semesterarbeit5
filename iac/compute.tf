# Resource Group – existiert bereits in Azure, wird hier unter Terraform-Verwaltung gebracht
resource "azurerm_resource_group" "main" {
  name     = "rg-zerotrust-finops-poc"
  location = "switzerlandnorth"
  tags     = var.tags
}

# Storage Account – wird vom Function-App-Runtime benötigt (Trigger-Verwaltung, Logs)
resource "azurerm_storage_account" "func" {
  name                     = "stzerotrustfinopspoc"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  tags                     = var.tags
}

# App Service Plan – Consumption (Y1), serverlos und im Studenten-Guthaben praktisch kostenlos
resource "azurerm_service_plan" "func" {
  name                = "asp-zerotrust-finops-poc"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "Y1"
  tags                = var.tags
}

# Function App mit System-Assigned Managed Identity (Zero Trust: keine statischen Credentials)
resource "azurerm_linux_function_app" "main" {
  name                        = "func-zerotrust-finops-poc"
  resource_group_name         = azurerm_resource_group.main.name
  location                    = azurerm_resource_group.main.location
  service_plan_id             = azurerm_service_plan.func.id
  storage_account_name        = azurerm_storage_account.func.name
  storage_account_access_key  = azurerm_storage_account.func.primary_access_key

  site_config {
    application_stack {
      python_version = "3.11"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

output "function_app_principal_id" {
  value = azurerm_linux_function_app.main.identity[0].principal_id
}

output "function_app_default_hostname" {
  value = azurerm_linux_function_app.main.default_hostname
}