#!/usr/bin/env python3
"""Statischer Tag-Compliance-Check für Terraform-Ressourcen (US-12 AK4).
Prüft, ob alle taggbaren azurerm_*-Ressourcen ein 'tags'-Attribut besitzen.
Bricht mit Exit-Code 1 ab, falls Ressourcen ohne Tags gefunden werden.
"""
import re
import sys
from pathlib import Path

# Ressourcentypen, die in Azure/Entra ID grundsätzlich KEINE Tags unterstützen
EXCLUDED_TYPES = {
    "azurerm_role_assignment",
    "azurerm_key_vault_secret",
    "azurerm_key_vault_access_policy",
    "azurerm_monitor_diagnostic_setting",
    "azurerm_key_vault_key",
    "azurerm_key_vault_certificate",
    "azurerm_consumption_budget_subscription",   # Budgets unterstützen keine Tags (Provider-Doku)
    "azurerm_subscription_policy_assignment",    # Policy Assignments unterstützen keine Tags (Provider-Doku)
}
# Ganze Provider, deren Ressourcen keine Azure-Tags kennen (Entra ID)
EXCLUDED_PREFIXES = ("azuread_", "data ")

RESOURCE_RE = re.compile(r'resource\s+"(?P<type>\w+)"\s+"(?P<name>\w+)"\s*\{')


def find_blocks(text: str):
    """Findet resource-Blöcke inkl. Inhalt via Brace-Counting."""
    blocks = []
    for m in RESOURCE_RE.finditer(text):
        rtype, rname = m.group("type"), m.group("name")
        start = m.end() - 1  # Position der öffnenden '{'
        depth = 0
        i = start
        while i < len(text):
            if text[i] == "{":
                depth += 1
            elif text[i] == "}":
                depth -= 1
                if depth == 0:
                    break
            i += 1
        body = text[start:i + 1]
        blocks.append((rtype, rname, body))
    return blocks


def main():
    iac_dir = Path(__file__).resolve().parent.parent / "iac"
    tf_files = sorted(iac_dir.glob("*.tf"))

    if not tf_files:
        print(f"::error::Keine .tf-Dateien in {iac_dir} gefunden.")
        sys.exit(1)

    violations = []

    for tf_file in tf_files:
        text = tf_file.read_text(encoding="utf-8")
        for rtype, rname, body in find_blocks(text):
            if rtype.startswith("azuread_") or rtype in EXCLUDED_TYPES:
                continue
            if not rtype.startswith("azurerm_"):
                continue
            if not re.search(r"\btags\s*=", body):
                violations.append(f"{tf_file.name}: {rtype}.{rname} hat kein 'tags'-Attribut")

    if violations:
        print("❌ Tag-Compliance-Check fehlgeschlagen:\n")
        for v in violations:
            print(f"  - {v}")
        print(f"\n{len(violations)} Ressource(n) ohne Pflicht-Tags gefunden.")
        sys.exit(1)

    print("✅ Tag-Compliance-Check bestanden: alle taggbaren Ressourcen haben ein 'tags'-Attribut.")
    sys.exit(0)


if __name__ == "__main__":
    main()