module "naming" {
  source      = "Azure/naming/azurerm"
  version     = "0.3.0"
  suffix      = [var.pname, var.environment]
  unique-seed = "random"
}
