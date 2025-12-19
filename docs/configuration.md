# Configuration Guide

The configuration is split into logical domains to simplify management and reduce error blast radius. All configuration files are located in the `config/` directory.

## 1. Common Settings (`config/common.auto.tfvars`)

Use this file for global variables that apply across the entire infrastructure.

| Variable       | Description                         | Example                                 |
| :------------- | :---------------------------------- | :-------------------------------------- |
| `pname`        | Project or Product name prefix      | `"contoso"`                             |
| `environment`  | Environment suffix                  | `"prod"`                                |
| `default_tags` | Global tags for all resources       | `{ owner = "cloud-team" }`              |
| `dns_zones`    | List of Private DNS Zones to create | `["privatelink.blob.core.windows.net"]` |

### vWAN Configuration (`config/vwan.auto.tfvars`)

Defines the Hubs and their features.

**Note on Naming:** This template uses **Strict Centralized Naming**. You do not provide resource names manually. They are generated based on `pname`, `environment`, and `location`.

```hcl
vwan_config = {
  location            = "eastus"

  hubs = {
    "hub_eastus" = {
      location       = "eastus"
      address_prefix = "10.0.0.0/24"

      firewall = {
        enabled = true
        sku_tier = "Standard"
      }
    }
  }
}
```

## 3. Spokes (`config/spokes.auto.tfvars`)

Defines the workloads. This is the most frequently edited file.

### Adding a Spoke

Add a new key to the `spokes` map.

```hcl
spokes = {
  "my-new-app" = {
    location          = "eastus"
    address_space     = ["10.50.0.0/16"]
    connected_hub_key = "hub_eastus" # Must match key in vwan config
    subnets = {
      "web" = {
        address_prefixes = ["10.50.1.0/24"]
        create_nsg       = true
        # Define rules inline
        nsg_rules = {
           "allow_http" = { ... }
        }
      }
    }
  }
}
```
