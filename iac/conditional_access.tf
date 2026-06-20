data "azuread_client_config" "current" {}

# Dedizierte Test-Gruppe – schützt den restlichen, geteilten Demo-Tenant vor den eigenen CAPs
resource "azuread_group" "poc_test_users" {
  display_name     = "sg-zerotrust-finops-poc-users"
  security_enabled = true
  owners           = [data.azuread_client_config.current.object_id]
  members          = [data.azuread_client_config.current.object_id]
}

# CAP-01: MFA erzwingen (geringes Risiko – nur Test-Gruppe betroffen)
resource "azuread_conditional_access_policy" "cap01_mfa" {
  display_name = "CAP-01 MFA erzwingen (PoC)"
  state         = "enabled"

  conditions {
    client_app_types = ["all"]

    applications {
      included_applications = ["All"]
    }

    users {
      included_groups = [azuread_group.poc_test_users.object_id]
    }
  }

  grant_controls {
    operator           = "OR"
    built_in_controls  = ["mfa"]
  }
}

# CAP-03: Legacy-Auth blockieren (praktisch risikofrei – niemand nutzt Legacy-Auth in diesem PoC)
resource "azuread_conditional_access_policy" "cap03_block_legacy_auth" {
  display_name = "CAP-03 Legacy-Auth blockieren (PoC)"
  state         = "enabled"

  conditions {
    client_app_types = ["exchangeActiveSync", "other"]

    applications {
      included_applications = ["All"]
    }

    users {
      included_groups = [azuread_group.poc_test_users.object_id]
    }
  }

  grant_controls {
    operator           = "OR"
    built_in_controls  = ["block"]
  }
}

# CAP-02: Gerätecompliance & Standort – bewusst NUR auf die Azure-CLI-App begrenzt,
# damit der Portal-Zugriff im Fehlerfall immer erhalten bleibt
resource "azuread_conditional_access_policy" "cap02_device_compliance" {
  display_name = "CAP-02 Gerätecompliance (PoC)"
  state         = "enabled"

  conditions {
    client_app_types = ["all"]

    applications {
      included_applications = ["797f4846-ba00-4fd7-ba43-dac1f8f63013"] # Windows Azure Service Management API
    }

    users {
      included_groups = [azuread_group.poc_test_users.object_id]
    }

    locations {
      included_locations = ["All"]
      excluded_locations = ["AllTrusted"]
    }
  }

  grant_controls {
    operator           = "AND"
    built_in_controls  = ["compliantDevice"]
  }
}