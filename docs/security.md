# Architecture & Design

## Security Configuration

### 1. Secured Virtual Hubs (Azure Firewall)

Enable the Firewall in your Hub config (`config/vwan.auto.tfvars`):

```hcl
hubs = {
  "hub_eastus" = {
    firewall = { enabled = true, sku_tier = "Standard" }
  }
}
```

### 2. Firewall Policies & Rules

We separate Policy/Rule definitions from the Hub configuration to support scale.
Policies are defined in `config/firewall_policies/*.auto.tfvars`.

#### Auto-Linkage

If you name your policy `policy-<location>` (e.g., `policy-eastus`), the template automatically applies it to the Hub in that location.

#### Directory Structure

```
config/
└── firewall_policies/
    ├── policy_eastus.auto.tfvars
    ├── policy_westeurope.auto.tfvars
    └── policy_shared.auto.tfvars
```

#### Example Rule Definition

Each policy file defines `rule_collection_groups`.

```hcl
firewall_policies = {
  "policy-eastus" = {
    name     = "afwp-eastus"
    location = "eastus"
    rule_collection_groups = {
      "app-rules" = {
        priority = 1000
        network_rule_collections = { ... }
        application_rule_collections = { ... }
      }
    }
  }
}
```

### 3. Spoke Security (NSGs)

Spoke security is managed in `config/spokes.auto.tfvars` at the subnet level.
