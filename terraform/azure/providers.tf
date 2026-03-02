terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }

  # ---------------------------------------------------------------------------
  # Remote State — Azure Blob Storage
  # ---------------------------------------------------------------------------
  # IMPORTANT: The storage account and container must be created BEFORE running
  # `terraform init`. Run the bootstrap commands below once:
  #
  #   RESOURCE_GROUP="expense-tracker-tfstate-rg"
  #   STORAGE_ACCOUNT="expensetfstate$(date +%s)"   # must be globally unique
  #   CONTAINER="tfstate"
  #   LOCATION="eastus"
  #
  #   az group create --name $RESOURCE_GROUP --location $LOCATION
  #
  #   az storage account create \
  #     --name $STORAGE_ACCOUNT \
  #     --resource-group $RESOURCE_GROUP \
  #     --location $LOCATION \
  #     --sku Standard_LRS \
  #     --kind StorageV2 \
  #     --encryption-services blob \
  #     --https-only true \
  #     --min-tls-version TLS1_2
  #
  #   az storage container create \
  #     --name $CONTAINER \
  #     --account-name $STORAGE_ACCOUNT
  # ---------------------------------------------------------------------------
  backend "azurerm" {
    resource_group_name  = "expense-tracker-tfstate-rg"
    storage_account_name = "expensetfstate" # replace with your unique name
    container_name       = "tfstate"
    key                  = "azure/expense-tracker/terraform.tfstate"
    # State is encrypted at rest automatically by Azure Blob Storage
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}
