provider "azurerm" {
  subscription_id = var.subscription_id  # Reference subscription ID from variables
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}