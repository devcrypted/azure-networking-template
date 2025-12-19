spokes = {
  "app_prod_eastus" = {
    location          = "eastus"
    address_space     = ["10.10.0.0/16"]
    connected_hub_key = "hub_eastus"

    subnets = {
      "frontend" = {
        address_prefixes   = ["10.10.1.0/24"]
        create_nsg         = true
        create_route_table = true

        nsg_rules = {
          "allow_https" = {
            priority                   = 100
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_port_range          = "*"
            destination_port_range     = "443"
            source_address_prefix      = "*"
            destination_address_prefix = "*"
          }
        }

        routes = {
          "to_firewall" = {
            address_prefix      = "0.0.0.0/0"
            next_hop_type       = "VirtualAppliance"
            next_hop_ip_address = "10.0.0.4" # Assume FW in Hub
          }
        }
      }
      "db" = {
        address_prefixes   = ["10.10.2.0/24"]
        create_nsg         = true
        create_route_table = false
        nsg_rules          = {}
        routes             = {}
      }
    }
  }
}
