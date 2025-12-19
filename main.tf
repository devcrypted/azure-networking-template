# 1. Resource Group for vWAN
resource "azurerm_resource_group" "vwan_rg" {
  name     = module.naming.resource_group.name_unique
  location = var.vwan_config.location
  tags     = var.default_tags
}

locals {
  # 1. Read all YAML files from config/firewall_rules
  fw_rule_files = fileset("${path.module}/config/firewall_rules", "*.yaml")

  # 2. Decode YAMLs
  fw_rules_decoded = [for f in local.fw_rule_files : yamldecode(file("${path.module}/config/firewall_rules/${f}"))]

  # 3. Group Rules by Policy Name
  # Map: "policy-name" => [ {group1}, {group2} ]
  fw_rules_by_policy = {
    for k, v in var.firewall_policies : k => merge([
      for r in local.fw_rules_decoded : r.rule_collection_groups
      if r.policy_name == k
    ]...)
  }
}

# 2. Deploy Firewall Policies (AVM Pattern)
module "firewall_policies" {
  source = "./modules/firewall_policy"

  for_each = var.firewall_policies

  # Use generated name for consistency
  name = "afwp-${module.naming.firewall_policy.slug}-${each.key}"

  resource_group_name = coalesce(each.value.resource_group_name, "rg-${var.pname}-${var.environment}")
  location            = each.value.location
  sku                 = each.value.sku
  base_policy_id      = each.value.base_policy_id

  # Merge explicit TF rules with YAML rules
  rule_collection_groups = merge(
    each.value.rule_collection_groups,
    lookup(local.fw_rules_by_policy, each.key, {})
  )
}

# 3. Deploy vWAN and Hubs (AVM Pattern)
module "virtual_wan" {
  source  = "Azure/avm-ptn-virtualwan/azurerm"
  version = "0.5.0"

  resource_group_name            = azurerm_resource_group.vwan_rg.name
  location                       = var.vwan_config.location
  virtual_wan_name               = module.naming.virtual_wan.name_unique
  virtual_wan_tags               = var.default_tags
  allow_branch_to_branch_traffic = var.vwan_config.allow_branch_to_branch_traffic

  virtual_hubs = {
    for k, v in var.vwan_config.hubs : k => {
      name           = "vhub-${module.naming.virtual_wan.slug}-${v.location}"
      location       = v.location
      address_prefix = v.address_prefix
      tags           = var.default_tags

      express_route_gateway = v.express_route_gateway.enabled ? {
        sku         = v.express_route_gateway.sku
        scale_units = v.express_route_gateway.scale_units
      } : null

      vpn_gateway = v.vpn_gateway.enabled ? {
        scale_units = v.vpn_gateway.scale_units
      } : null

      firewall = v.firewall.enabled ? {
        sku_name           = v.firewall.sku_name
        sku_tier           = v.firewall.sku_tier
        firewall_policy_id = v.firewall.firewall_policy_id != null ? v.firewall.firewall_policy_id : (lookup(var.firewall_policies, "policy-${v.location}", null) != null ? module.firewall_policies["policy-${v.location}"].resource_id : null)
      } : null
    }
  }
}

# 3. Create Private DNS Zones (Global/Regional as needed)
# Using AVM Resource for DNS Zone
module "private_dns_zones" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.1.2"

  for_each = var.dns_zones

  resource_group_name = azurerm_resource_group.vwan_rg.name # Centrally located
  domain_name         = each.key
  tags                = var.default_tags

  # Link to all Hub VNets?
  # vWAN Hubs are managed, you usually link to Spokes or a specific DNS resolver VNet.
  # For simplicity, we just create the zones here. Linking strategy relies on Policy or manual links.
}

# 4. Spoke Resource Groups
resource "azurerm_resource_group" "spoke_rgs" {
  for_each = var.spokes

  name     = "rg-${module.naming.resource_group.slug}-${each.key}-${each.value.location}"
  location = each.value.location
  tags     = var.default_tags
}

# 5. Spoke Wrapper Instantiation
module "spokes" {
  source = "./modules/spoke_vnet"

  for_each = var.spokes

  name                = "vnet-${module.naming.virtual_network.slug}-${each.key}-${each.value.location}"
  resource_group_name = azurerm_resource_group.spoke_rgs[each.key].name
  location            = each.value.location
  address_space       = each.value.address_space
  tags                = var.default_tags

  subnets = each.value.subnets

  # Connect to the correct Hub
  connected_hub_id = module.virtual_wan.resource[each.value.connected_hub_key].id
}
