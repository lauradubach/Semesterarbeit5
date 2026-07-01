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