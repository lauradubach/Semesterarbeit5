variable "tags" {
  description = "Gemeinsame Pflicht-Tags (environment, workload) für alle Azure-Ressourcen. Der team-Tag wird pro Ressource über locals ergänzt."
  type        = map(string)
  default = {
    environment = "poc"
    workload    = "zerotrust-finops-poc"
  }
}

locals {
  identity_tags    = merge(var.tags, { team = "identity-poc" })
  governance_tags  = merge(var.tags, { team = "governance-poc" })
}

variable "location" {
  description = "Azure-Region für alle Ressourcen"
  type        = string
  default     = "switzerlandnorth"
}

variable "aad_tenant_id" {
  description = "Entra ID Tenant ID für die Function-App-Authentifizierung"
  type        = string
}

variable "aad_audience" {
  description = "Erwartete Audience (App Registration URI) für Token-Validierung"
  type        = string
}

variable "budget_amount" {
  description = "Monatliches Budget pro Team in der Subscription-Währung"
  type        = number
  default     = 5
}

variable "budget_start_date" {
  description = "Startdatum der Budget-Periode (ISO 8601, erster Tag des Monats)"
  type        = string
  default     = "2026-07-01T00:00:00Z"
}

variable "budget_end_date" {
  description = "Enddatum der Budget-Periode (ISO 8601)"
  type        = string
  default     = "2027-07-01T00:00:00Z"
}

variable "excluded_resource_group" {
  description = "Resource Group, die von den Tag-Compliance-Policies ausgenommen wird (bestehende Tenant-Alt-Ressource ausserhalb des PoC-Scopes)"
  type        = string
  default     = "test"
}
variable "budget_alert_email" {
  description = "E-Mail-Adresse für Budget-Alerts (US-14)"
  type        = string
  default     = "laura.dubach@edu.tbz.ch"
}

variable "enable_budgets" {
  description = "Aktiviert die Erstellung von Azure Cost Management Budgets. Standardmässig 'false', da Budgets für Subscriptions vom Typ 'Microsoft Azure Sponsorship' (Offer MS-AZR-0036P) nicht unterstützt werden (siehe US-14/US-15 Dokumentation). Der Code bleibt vollständig funktionsfähig für Subscriptions mit unterstütztem Offer-Typ (Pay-As-You-Go, EA, MCA)."
  type        = bool
  default     = false
}