firewall_policies = {
  "policy-eastus" = {
    location            = "eastus"
    resource_group_name = "rg-connectivity-global"
    sku                 = "Standard"

    rule_collection_groups = {
      "core-infra-rules" = {
        priority = 1000
        network_rule_collections = {
          "allow-dns" = {
            priority = 100
            action   = "Allow"
            rules = {
              "dns-google" = {
                protocols             = ["UDP"]
                destination_ports     = ["53"]
                source_addresses      = ["*"]
                destination_addresses = ["8.8.8.8"]
              }
            }
          }
        }
      }
    }
  }
}
