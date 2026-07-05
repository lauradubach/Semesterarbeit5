data "azurerm_client_config" "current" {}

# Key Vault – RBAC-Autorisierung statt klassischer Access Policies (passt zum Zero-Trust-Ansatz)
resource "azurerm_key_vault" "main" {
  name                       = "kv-zerotrust-finops-poc"
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  enable_rbac_authorization  = true
  purge_protection_enabled   = true
  soft_delete_retention_days = 90
  tags                       = local.governance_tags   # ← geändert
}

# Wichtig: Bei RBAC-Autorisierung bekommst du als Deployer KEINEN automatischen Zugriff
# (anders als beim alten Access-Policy-Modell) – diese Rolle brauchst du, um selbst Secrets anzulegen
resource "azurerm_role_assignment" "kv_admin_self" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id          = data.azurerm_client_config.current.object_id
}

# US-07: Function App MI bekommt NUR Lesezugriff auf Secrets (Least Privilege)
resource "azurerm_role_assignment" "function_kv_secrets_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id          = azurerm_linux_function_app.main.identity[0].principal_id
}

# Mindestens ein Secret (US-08 Akzeptanzkriterium)
resource "azurerm_key_vault_secret" "demo_secret" {
  name         = "poc-demo-secret"
  value        = "ZeroTrust-FinOps-PoC-Wert"
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_role_assignment.kv_admin_self]
}

# Log Analytics Workspace + Diagnostic Setting (US-08: Zugriffsprotokollierung → Azure Monitor)
resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-zerotrust-finops-poc"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.governance_tags
}

resource "azurerm_monitor_diagnostic_setting" "kv_diag" {
  name                       = "diag-kv-zerotrust-finops-poc"
  target_resource_id         = azurerm_key_vault.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "AuditEvent"
  }

  metric {
    category = "AllMetrics"
  }
}