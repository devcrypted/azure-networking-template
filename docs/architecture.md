# Architecture & Design

This solution adheres to the **Separation of Concerns** principle.

## Directory Structure

```
/
├── main.tf                 # Orchestration of vWAN, Hubs, and Spoke Iteration
├── variables.tf            # Logic-split variable definitions
├── naming.tf               # Centralized Naming Module configuration
├── config/                 # Configuration Layer (User Space)
│   ├── common.auto.tfvars  # Tags, Project Name, DNS Zones
│   ├── vwan.auto.tfvars    # Core Networking (Hubs, Gateways)
│   └── spokes.auto.tfvars  # Workloads (VNets, Subnets, NSGs)
└── modules/
    └── spoke_vnet/         # Local Wrapper Module
```

## The Spoke Wrapper Module (`modules/spoke_vnet`)

To adhere to DRY (Don't Repeat Yourself) and ensure consistency, all Spokes are deployed via this wrapper. It encapsulates:

1.  **VNet Creation**: via `Azure/avm-res-network-virtualnetwork`.
2.  **Security**: Automatically deploys AVM-compliant NSGs if `create_nsg = true`.
3.  **Routing**: Automatically deploys Route Tables if `create_route_table = true`.
4.  **Connection**: Manages the peering connection to the specified vWAN Hub.

## Design Decisions

### Why `modules/spoke_vnet`?

You might ask: _"Why not use the AVM VNet module directly in main.tf?"_

The `modules/spoke_vnet` is a **Composition Module**. It orchestrates multiple independent AVM modules and resources to work together as a single logical unit.

- **Problem**: The AVM VNet module creates VNets, but it _does not_ create NSGs, Route Tables, or vWAN Connections. It only accepts _IDs_ of existing resources.
- **Solution**: The wrapper module:
  1.  Creates the NSG (using `avm-res-network-networksecuritygroup`).
  2.  Creates the Route Table (using native resources, as AVM RT is arguably overkill for simple static routes, though swappable).
  3.  Creates the VNet (using `avm-res-network-virtualnetwork`) and automatically injects the IDs of the NSG/RT created above.
  4.  Creates the `azurerm_virtual_hub_connection` to link everything to the vWAN.

Without this wrapper, `main.tf` would require 5 separate loops with complex cross-referencing logic, making the code brittle and hard to read.

## Naming Convention

We use the `Azure/naming` module. Resources are not hardcoded but generated:

- vWAN: `vwan-<pname>-<env>-<location>` (unless overridden)
- VNet: `vnet-<pname>-<env>-<location>-<name>`

## Extensibility

To add a new Firewall Rule to a subnet:

1.  Open `config/spokes.auto.tfvars`.
2.  Navigate to the specific subnet.
3.  Add the rule to the `nsg_rules` map.
    _(No changes to `main.tf` or `variables.tf` required)_
