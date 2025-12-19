# Azure Hub & Spoke v2 Template

## Overview

This repository contains a production-ready, highly scalable Terraform template for deploying a **Hub and Spoke** network topology on Microsoft Azure using **Virtual WAN**.

It is designed with **Azure Landing Zones (ALZ)** principles in mind, utilizing **Azure Verified Modules (AVM)** to ensure best practices, security, and long-term maintainability.

## Key Features

- **Scalable Architecture**: Built on Azure Virtual WAN to support global scale with minimal complexity.
- **Secured Hubs**: Built-in support for Azure Firewall in the Virtual Hubs.
- **granular Security**: Zero-trust ready with granular NSGs and Route Tables automagically deployed for every Spoke Subnet.
- **Composition Model**: Uses a "Spoke Wrapper" pattern that bundles VNet, Peering, Security, and Routing into a single configuration block.
- **Configuration Driven**: 100% of the infrastructure is defined in `config/*.auto.tfvars` files. No need to touch Terraform logic code for standard operations.

## Architecture

The solution allows for a multi-region deployment managed from a central configuration.

- **Hubs**: Managed Virtual WAN Hubs (optionally secured with Azure Firewall).
- **Spokes**: Standard Azure VNets peered to the Hubs.
- **DNS**: Centralized Private DNS Management.

For deep dives, see the documentation:

- 🏗️ **[Architecture Design](docs/architecture.md)**: Detailed breakdown of the modules and logic.
- 🛡️ **[Security Model](docs/security.md)**: Explanation of Secured Hubs, NSGs, and Firewall roles.
- ⚙️ **[Configuration Guide](docs/configuration.md)**: Reference guide for variable files.
- 🚀 **[CI/CD Pipelines](docs/cicd.md)**: How to automate deployments.

## Directory Structure

```
/
├── config/                 # <--- YOU WORK HERE
│   ├── common.auto.tfvars  # Global settings (Tags, DNS)
│   ├── vwan.auto.tfvars    # Hub definitions
│   └── spokes.auto.tfvars  # Spoke configurations
├── modules/                # Local helper modules
├── docs/                   # Detailed documentation
└── main.tf                 # Core logic (Do not edit usually)
```

## Usage

To run Terraform with this modular configuration, you must explicitly load the variable files:

```bash
terraform plan \
  -var-file=config/common.auto.tfvars \
  -var-file=config/vwan.auto.tfvars \
  -var-file=config/spokes.auto.tfvars \
  -var-file=config/firewall_policies/policy_eastus.auto.tfvars
```

Or better yet, use the provided CI/CD pipelines which handle this automatically.

## Quick Start

1.  **Clone** this repository.
2.  **Initialize** Terraform:
    ```bash
    terraform init
    ```
3.  **Plan** your deployment:
    ```bash
    terraform plan -out main.tfplan
    ```
4.  **Apply**:
    ```bash
    terraform apply main.tfplan
    ```
