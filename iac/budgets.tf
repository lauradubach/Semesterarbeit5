# US-14: Budget-Alerts pro Team-Tag-Wert
# Zwei separate Budgets, je eines pro simuliertem Team (siehe US-12),
# damit Kostengrenzen pro Verantwortungsbereich überwacht werden können.

locals {
  budget_teams = ["identity-poc", "governance-poc"]
}

resource "azurerm_consumption_budget_subscription" "team_budget" {
  for_each        = toset(local.budget_teams)
  name            = "budget-${each.value}"
  subscription_id = data.azurerm_subscription.current.id
  amount          = 5
  time_grain      = "Monthly"

  time_period {
    start_date = "2026-07-01T00:00:00Z"
    end_date   = "2027-07-01T00:00:00Z"
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