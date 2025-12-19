variable "name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "sku" { type = string }
variable "base_policy_id" {
  type    = string
  default = null
}

variable "rule_collection_groups" {
  type = map(object({
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
  }))
}
