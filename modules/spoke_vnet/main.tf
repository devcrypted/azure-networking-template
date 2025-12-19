terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

# 1. Create Route Tables if requested
resource "azurerm_route_table" "rt" {
  for_each = {
    for k, v in var.subnets : k => v if v.create_route_table
  }

  name                          = "rt-${var.name}-${each.key}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  bgp_route_propagation_enabled = true
  tags                          = var.tags
}

resource "azurerm_route" "routes" {
  for_each = merge([
    for subnet_key, subnet in var.subnets : {
      for route_key, route in subnet.routes : "${subnet_key}-${route_key}" => merge(route, {
        rt_name = azurerm_route_table.rt[subnet_key].name
      })
    } if subnet.create_route_table
  ]...)

  name                   = each.key
  resource_group_name    = var.resource_group_name
  route_table_name       = each.value.rt_name
  address_prefix         = each.value.address_prefix
  next_hop_type          = each.value.next_hop_type
  next_hop_in_ip_address = each.value.next_hop_ip_address
}

# 2. Create NSGs if requested
# Using AVM NSG module for best practice compliance?
# Actually, iterating AVM modules inside a module is verbose for NSGs.
# Resource block is standard for this level of granularity, but user asked for AVM.
# Let's use AVM NSG module.
module "nsg" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.2.0"

  for_each = {
    for k, v in var.subnets : k => v if v.create_nsg
  }

  resource_group_name = var.resource_group_name
  location            = var.location
  name                = "nsg-${var.name}-${each.key}"
  tags                = var.tags

  security_rules = {
    for r_name, r_conf in each.value.nsg_rules : r_name => merge(r_conf, {
      name = r_name
    })
  }
}

# 3. Create VNet and Subnets
module "vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.4.0"

  resource_group_name = var.resource_group_name
  name                = var.name
  location            = var.location
  address_space       = var.address_space
  tags                = var.tags

  subnets = {
    for s_name, s_conf in var.subnets : s_name => {
      name             = s_name
      address_prefixes = s_conf.address_prefixes

      # Association
      network_security_group = s_conf.create_nsg ? {
        id = module.nsg[s_name].resource_id
      } : null

      route_table = s_conf.create_route_table ? {
        id = azurerm_route_table.rt[s_name].id
      } : null
    }
  }
}

# 4. Connection to vWAN Hub
resource "azurerm_virtual_hub_connection" "conn" {
  name                      = "${var.name}-conn"
  virtual_hub_id            = var.connected_hub_id
  remote_virtual_network_id = module.vnet.resource_id
  internet_security_enabled = true
}
