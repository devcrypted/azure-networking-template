# --- Global Settings ---
variable "pname" {
  description = "Project or Product name for naming convention."
  type        = string
  default     = "contoso"
}

variable "environment" {
  description = "Environment name (e.g., prod, dev) for naming convention."
  type        = string
  default     = "dev"
}

variable "default_tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}

# --- vWAN Configuration ---
variable "vwan_config" {
  description = "Configuration for Virtual WAN and Hubs."
  type = object({
    name                           = optional(string) # Optional override
    resource_group_name            = optional(string)
    location                       = string
    allow_branch_to_branch_traffic = optional(bool, true)

    hubs = map(object({
      # name attribute removed to enforce naming convention
      location       = string
      address_prefix = string

      # Gateways
      express_route_gateway = optional(object({
        enabled     = bool
        sku         = optional(string, "Standard")
        scale_units = optional(number, 1)
      }), { enabled = false })

      vpn_gateway = optional(object({
        enabled     = bool
        scale_units = optional(number, 1)
      }), { enabled = false })

      firewall = optional(object({
        enabled            = bool
        sku_name           = optional(string, "AZFW_Hub")
        sku_tier           = optional(string, "Standard")
        firewall_policy_id = optional(string)
      }), { enabled = false })
    }))
  })

  validation {
    condition     = alltrue([for k, v in var.vwan_config.hubs : can(cidrhost(v.address_prefix, 0))])
    error_message = "All Hub address_prefixes must be valid CIDR ranges."
  }
}

# --- Spokes Configuration ---
variable "spokes" {
  description = "Map of Spoke VNet configurations."
  type = map(object({
    # name attribute removed to enforce naming convention
    resource_group_name = optional(string) # Optional override, but we prefer generated
    location            = string
    address_space       = list(string)
    connected_hub_key   = string # Must match key in vwan_config.hubs

    # Subnets Configuration
    subnets = map(object({
      address_prefixes = list(string)

      # NSG Config
      create_nsg = optional(bool, true)
      nsg_rules = optional(map(object({
        priority                   = number
        direction                  = string
        access                     = string
        protocol                   = string
        source_port_range          = string
        destination_port_range     = string
        source_address_prefix      = string
        destination_address_prefix = string
      })), {})

      # Route Table Config
      create_route_table = optional(bool, true)
      routes = optional(map(object({
        address_prefix      = string
        next_hop_type       = string
        next_hop_ip_address = optional(string)
      })), {})
    }))
  }))

  validation {
    condition     = alltrue([for k, v in var.spokes : alltrue([for cidr in v.address_space : can(cidrhost(cidr, 0))])])
    error_message = "All Spoke address_spaces must be valid CIDR ranges."
  }
}

# --- Shared Services ---
variable "dns_zones" {
  description = "List of Private DNS Zones to create and link to Hubs."
  type        = set(string)
  default     = []
}

# --- Azure Firewall Policies ---
variable "firewall_policies" {
  description = "Map of Firewall Policies to create."
  type = map(object({
    # name attribute removed to enforce naming convention
    resource_group_name = optional(string)
    location            = string
    sku                 = optional(string, "Standard")
    base_policy_id      = optional(string)

    rule_collection_groups = optional(map(object({
      priority = number
      network_rule_collections = optional(map(object({
        priority = number
        action   = string
        rules = map(object({
          protocols             = list(string)
          destination_ports     = list(string)
          source_addresses      = optional(list(string))
          destination_addresses = list(string)
        }))
      })), {})
      application_rule_collections = optional(map(object({
        priority = number
        action   = string
        rules = map(object({
          protocols = list(object({
            type = string
            port = number
          }))
          source_addresses  = optional(list(string))
          destination_fqdns = optional(list(string))
        }))
      })), {})
    })), {})
  }))
  default = {}
}
