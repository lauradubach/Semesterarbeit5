variable "tags" {
  description = "Pflicht-Tags für alle Azure-Ressourcen"
  type        = map(string)
  default = {
    team        = "cloud-engineering"
    environment = "dev"
    workload    = "zero-trust-poc"
  }
}