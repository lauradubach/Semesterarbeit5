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

## Bekannte Plattform-Einschränkungen

Diese PoC-Subscription läuft unter dem Offer-Typ „Microsoft Azure Sponsorship"
(`MS-AZR-0036P`). Dabei wurden zwei von Microsoft dokumentierte Einschränkungen
festgestellt:

- **Azure Cost Management** (Budgets, Cost Analysis, Kostenaufschlüsselung nach
  Betrag) wird für diesen Offer-Typ nicht unterstützt. Die Terraform-Ressourcen
  für Budget-Alerts sind vollständig implementiert (`iac/budgets.tf`), aber
  standardmässig über `enable_budgets = false` deaktiviert. Als Ersatznachweis
  für den E-Mail-Benachrichtigungskanal dient eine Azure Monitor Action Group.
- Das alternative **Sponsorship-Verbrauchsportal** ist nur für den
  Subscription-Owner-Account zugänglich, nicht für zugewiesene Benutzer im
  Demo-Tenant-Setup. Als Ersatz für das Cost-Dashboard wurde ein
  Azure-Portal-Dashboard mit Resource-Graph-Kacheln (Ressourcenverteilung nach
  `team`/`workload`-Tag) erstellt.

Details und Screenshots dazu siehe Semesterarbeit, Kapitel US-14/US-15.

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
├── scripts/      # Hilfsskripte (u.a. Tag-Compliance-Check)
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
Eine Vorlage ohne echte Werte liegt unter `iac/terraform.tfvars.example`.

### Tag-Compliance-Check (lokal)

```bash
python scripts/check_tags.py
```

Prüft, ob alle taggbaren Terraform-Ressourcen die Pflicht-Tags besitzen. Läuft
zusätzlich automatisch bei jedem Push via GitHub Actions
(`.github/workflows/tag-compliance.yml`).

### Umgebung aufräumen

```bash
terraform destroy
```

⚠️ **Wichtiger Hinweis:** Der Key Vault (`kv-zerotrust-finops-poc`) ist mit
`purge_protection_enabled = true` konfiguriert (Zero-Trust-Best-Practice gegen
versehentliches/böswilliges Löschen). Ein `destroy` entfernt ihn zwar
(Soft-Delete), der Name bleibt jedoch für `soft_delete_retention_days` (90 Tage)
reserviert und kann in dieser Zeit **nicht** neu angelegt werden. Ein
vollständiger Destroy-Test wurde im Rahmen dieser Arbeit deshalb bewusst nicht
live durchgeführt, um die PoC-Umgebung nicht zu gefährden — stattdessen wurde
das Verhalten mit `terraform plan -destroy` simuliert und dokumentiert
(siehe Semesterarbeit, Kapitel US-16).

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
