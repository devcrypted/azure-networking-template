variable "name" {
  description = "The name of the connection."
  type        = string
}

variable "virtual_hub_id" {
  description = "The ID of the Virtual Hub."
  type        = string
}

variable "remote_virtual_network_id" {
  description = "The ID of the remote Virtual Network."
  type        = string
}

variable "internet_security_enabled" {
  description = "Should internet security be enabled?"
  type        = bool
  default     = true
}
