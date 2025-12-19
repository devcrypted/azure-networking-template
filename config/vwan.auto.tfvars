vwan_config = {
  location = "eastus"

  hubs = {
    # Hub 1: East US - Standard Firewall, No ExpressRoute
    "hub_eastus" = {
      location       = "eastus"
      address_prefix = "10.0.0.0/24"

      firewall = {
        enabled  = true
        sku_tier = "Standard"
        # firewall_policy_id = "/subscriptions/xxxx/resourceGroups/xxxx/providers/Microsoft.Network/firewallPolicies/policy-eastus"
      }
    }

    # Hub 2: West Europe - Premium Firewall AND ExpressRoute
    "hub_westeurope" = {
      location       = "westeurope"
      address_prefix = "10.1.0.0/24"

      express_route_gateway = {
        enabled     = true
        sku         = "Standard"
        scale_units = 1
      }

      firewall = {
        enabled  = true
        sku_tier = "Premium" # Different SKU than East US
        # firewall_policy_id = "/subscriptions/xxxx/resourceGroups/xxxx/providers/Microsoft.Network/firewallPolicies/policy-weu"
      }
    }
  }
}
