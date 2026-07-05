data "azurerm_subscription" "current" {}

data "azurerm_policy_definition_built_in" "require_tag" {
  display_name = "Require a tag on resources"
}

locals {
  required_tags = ["team", "environment", "workload"]
}

# US-13: Erzwingt die drei Pflicht-Tags auf Subscription-Ebene.
# enforce = true (Deny-Modus): Ressourcen ohne die Pflicht-Tags werden beim
# Deployment aktiv abgelehnt. Ursprünglich enforce = false (Audit-Modus/
# DoNotEnforce) zur risikofreien Verifizierung, siehe US-13-Dokumentation.
resource "azurerm_subscription_policy_assignment" "require_tag" {
  for_each             = toset(local.required_tags)
  name                 = "require-tag-${each.value}"
  policy_definition_id = data.azurerm_policy_definition_built_in.require_tag.id
  subscription_id      = data.azurerm_subscription.current.id
  display_name         = "Require tag '${each.value}' on resources"
  description          = "Erzwingt das Vorhandensein des Pflicht-Tags '${each.value}' auf allen Ressourcen (US-13, US-12)."
  enforce              = true

  # Ausnahme: Resource Group 'test' ist eine bestehende Tenant-Alt-Ressource
  # (asadmoneusponsortst01, Storage Account in North Europe) ausserhalb des
  # PoC-Scopes und wird nicht von diesem Projekt verwaltet.
not_scopes = [
  "/subscriptions/0576f223-f60a-4e64-839e-066b2558a5ec/resourceGroups/${var.excluded_resource_group}"
]

  parameters = jsonencode({
    tagName = {
      value = each.value
    }
  })

  non_compliance_message {
    content = "Ressourcen müssen den Tag '${each.value}' besitzen (Pflicht-Tag gemäss FinOps-Tagging-Strategie)."
  }
}