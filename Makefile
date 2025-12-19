# Makefile for Azure Networking Template

# Find all auto.tfvars in config/firewall_policies
FW_POLICIES := $(wildcard config/firewall_policies/*.auto.tfvars)

# Construct variable file arguments
TF_FLAGS := -var-file=config/vwan.auto.tfvars \
            -var-file=config/spokes.auto.tfvars \
            -var-file=config/common.auto.tfvars \
            $(foreach file,$(FW_POLICIES),-var-file=$(file))

.PHONY: all init plan apply validate fmt

all: init plan

init:
	terraform init

# Run plan. Usage: make plan
plan:
	terraform plan $(TF_FLAGS)

# Run apply. Usage: make apply
apply:
	terraform apply $(TF_FLAGS) -auto-approve

# Validate configuration
validate:
	terraform validate

# Format all files
fmt:
	terraform fmt -recursive
