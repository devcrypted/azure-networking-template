variable "name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "address_space" { type = list(string) }
variable "tags" { type = map(string) }

variable "subnets" {
  type = map(object({
    address_prefixes = list(string)
    create_nsg       = bool
    nsg_rules = map(object({
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    }))
    create_route_table = bool
    routes = map(object({
      address_prefix      = string
      next_hop_type       = string
      next_hop_ip_address = optional(string)
    }))
  }))
}

variable "connected_hub_id" {
  description = "Resource ID of the vWAN Hub to connect to."
  type        = string
}
