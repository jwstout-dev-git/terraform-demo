# Use the Azure Resource Manager Provider
provider "azurerm" {
  version = "~> 1.44.0"
}

# Create a new Resource Group
resource "azurerm_resource_group" "group" {
  name     = "webapp-containers-demo"
  location = "SouthCentralUS"
}

# Create an App Service Plan with Linux
resource "azurerm_app_service_plan" "appserviceplan" {
  name                = "webapptfplan"
  location            = "${azurerm_resource_group.group.location}"
  resource_group_name = "${azurerm_resource_group.group.name}"

  # Define Linux as Host OS
  kind = "Linux"
  reserved = true

  # Choose size
  sku {
    tier = "Standard"
    size = "S1"
  }

  #properties {
  #  reserved = true # Mandatory for Linux plans
 # }
}

# Create an Azure Web App for Containers in that App Service Plan
resource "azurerm_app_service" "dockerapp" {
  name                = "${azurerm_resource_group.group.name}-dockerapp"
  location            = "${azurerm_resource_group.group.location}"
  resource_group_name = "${azurerm_resource_group.group.name}"
  app_service_plan_id = "${azurerm_app_service_plan.appserviceplan.id}"

  # Do not attach Storage by default
 tags = {
    app_settings = "dockerapp"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false

    /*
    # Settings for private Container Registires  
    DOCKER_REGISTRY_SERVER_URL      = ""
    DOCKER_REGISTRY_SERVER_USERNAME = ""
    DOCKER_REGISTRY_SERVER_PASSWORD = ""
    */
  }

  # Configure Docker Image to load on start
  site_config {
    linux_fx_version = "DOCKER|appsvcsample/static-site:latest"
    always_on        = "true"
  }

  identity {
    type = "SystemAssigned"
  }
}