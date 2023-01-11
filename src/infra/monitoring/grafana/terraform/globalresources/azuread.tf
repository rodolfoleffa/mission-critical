data "azuread_client_config" "current" {}

# App registration for the auth manager to be able to validate requests against Azure AD
resource "azuread_application" "auth" {
  display_name     = "${lower(var.prefix)}-auth"
  identifier_uris  = ["api://example-app"]
  owners           = [data.azuread_client_config.current.object_id]
  sign_in_audience = "AzureADMyOrg"

  group_membership_claims = [ "SecurityGroup", "ApplicationGroup" ]

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # ID of Microsoft Graph

    resource_access {
        id   = "98830695-27a2-44f7-8c18-0c3ebc9698f6"
        type = "Role"
    }
  }

  web {
    redirect_uris = ["https://${var.custom_fqdn != "" ? var.custom_fqdn : azurerm_frontdoor.afdgrafana.cname}/login/azuread"]

  }
}

resource "azuread_application_password" "auth" {
  application_object_id = azuread_application.auth.object_id
}
