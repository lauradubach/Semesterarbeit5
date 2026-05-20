# Zero Trust Workload Identity + FinOps Tagging auf Azure

> 5. Semesterarbeit · Dipl. Informatikerin HF Cloud-native Engineer · ITCNE24 · TBZ Zürich

---

## Über dieses Projekt

Dieser Proof of Concept zeigt, wie eine Azure-Umgebung nach **Zero Trust Prinzipien** aufgebaut werden kann — ohne ein einziges statisches Secret — und wie mittels **FinOps Tagging** vollständige Kostentransparenz erreicht wird.

| | |
|---|---|
| **Zeitraum** | 06. Mai 2026 – 08. Juli 2026 |
| **Autorin** | Laura Dubach |
| **Studiengang** | Dipl. Informatikerin HF – Cloud-native Engineer |
| **Klasse** | ITCNE24 · Technische Berufsschule Zürich |

---

## Ziele

| Ziel | Messkriterium |
|------|--------------|
| Zero Trust | Kein Service Principal mit statischem Secret im gesamten PoC |
| FinOps Tagging | 100% Tag-Compliance gemäss Azure Policy Compliance Report |
| Kostentransparenz | Alle Kosten sind vollständig einem Team zuordenbar |
| Infrastructure as Code | Komplettes Setup mit einem einzigen Befehl deploybar |

---

## Architektur

```
Azure Subscription
├── Microsoft Entra ID          → Managed Identities, Conditional Access
├── Azure Key Vault             → Secrets, Zertifikate (kein statisches Secret)
├── Azure Functions / Container Apps  → Workloads mit Managed Identity
├── Azure Policy                → Tag-Compliance erzwingen (Deny-Effekt)
└── Azure Cost Management       → Budget-Alerts, Dashboard, Showback-Report
```

Alle Ressourcen tragen die Pflicht-Tags `team`, `environment` und `workload`.

---

## Repository-Struktur

```
/
├── iac/          # Terraform-Skripte (Provider, Resources, Variables)
├── docs/         # Architekturdiagramm, Konzeptdokumente
├── src/          # Applikationscode (Azure Functions / Container)
├── README.md
└── toolchain.md  # Versionen aller eingesetzten Tools
```

---

## Deployment

```bash
# Voraussetzungen: Azure CLI, Terraform CLI, az login ausgeführt

cd iac/
terraform init
terraform plan
terraform apply
```

Alle Variablen befinden sich in `iac/terraform.tfvars` — keine Hardcoded-Werte.

```bash
# Umgebung vollständig aufräumen
terraform destroy
```

---

## Sprints

| Sprint | Zeitraum | Inhalt |
|--------|----------|--------|
| Sprint 1 | 06.05. – 26.05.2026 | Setup, Konzept, Architektur (US-01 – US-06) |
| Sprint 2 | 27.05. – 16.06.2026 | Zero Trust Implementierung (US-07 – US-11) |
| Sprint 3 | 17.06. – 07.07.2026 | FinOps, IaC, Abschluss (US-12 – US-19) |

---

## Eingesetzte Technologien

![Azure](https://img.shields.io/badge/Azure-0078D4?style=flat&logo=microsoftazure&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=flat&logo=terraform&logoColor=white)
![Entra ID](https://img.shields.io/badge/Entra_ID-0078D4?style=flat&logo=microsoft&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-181717?style=flat&logo=github&logoColor=white)

| Bereich | Technologie |
|---------|-------------|
| Identität | Microsoft Entra ID, Managed Identities, RBAC |
| Secrets | Azure Key Vault (Soft-Delete, Purge Protection, Audit Log) |
| Zugriffskontrolle | Conditional Access Policies (MFA, Gerätecompliance) |
| Workloads | Azure Functions / Container Apps |
| Kommunikation | mTLS / JWT |
| Compliance | Azure Policy (Deny-Effekt bei fehlenden Tags) |
| Kosten | Azure Cost Management, Budget-Alerts, Showback-Report |
| IaC | Terraform |
| IDE | Visual Studio Code |

---

## Autorin

**Laura Dubach**  
GitHub: [@lauradubach](https://github.com/lauradubach)  
E-Mail: laura.dubach@edu.tbz.ch
