# US-14: Budget-Alerts pro Team-Tag-Wert
# Zwei separate Budgets, je eines pro simuliertem Team (siehe US-12),
# damit Kostengrenzen pro Verantwortungsbereich überwacht werden können.

locals {
  budget_teams = ["identity-poc", "governance-poc"]
}

resource "azurerm_consumption_budget_subscription" "team_budget" {
  for_each        = var.enable_budgets ? toset(local.budget_teams) : toset([])
  name            = "budget-${each.value}"
  subscription_id = data.azurerm_subscription.current.id
  amount          = var.budget_amount
  time_grain      = "Monthly"

  time_period {
    start_date = var.budget_start_date
    end_date   = var.budget_end_date
  }

  filter {
    tag {
      name   = "team"
      values = [each.value]
    }
  }

  # Warnung bei 80% des Budgets
  notification {
    enabled        = true
    threshold      = 80.0
    operator       = "GreaterThanOrEqualTo"
    threshold_type = "Actual"
    contact_emails = [var.budget_alert_email]
  }

  # Kritisch bei 100% des Budgets
  notification {
    enabled        = true
    threshold      = 100.0
    operator       = "GreaterThanOrEqualTo"
    threshold_type = "Actual"
    contact_emails = [var.budget_alert_email]
  }
}

output "budget_names" {
  value = [for b in azurerm_consumption_budget_subscription.team_budget : b.name]
}

# US-14 (Ersatznachweis): Action Group für Budget-/Cost-Alerts.
# Azure Cost Management Budgets werden auf "Microsoft Azure Sponsorship"-
# Subscriptions (Offer MS-AZR-0036P, u.a. Azure for Students) nicht
# unterstützt (dokumentierte Microsoft-Einschränkung, kein Konfigurationsfehler).
# Diese Action Group dient als Nachweis, dass der E-Mail-Benachrichtigungskanal
# technisch funktioniert und bei einer unterstützten Subscription (Pay-As-You-Go,
# EA, MCA) direkt in den Budgets oben (contact_groups) wiederverwendet werden könnte.
resource "azurerm_monitor_action_group" "budget_alerts" {
  name                = "ag-budget-alerts-poc"
  resource_group_name = azurerm_resource_group.main.name
  short_name          = "budgetpoc"

  email_receiver {
    name          = "laura-dubach"
    email_address = var.budget_alert_email
  }

  tags = local.governance_tags
}