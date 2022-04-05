variable "region" {
  default     = "ap-southeast-1"
  description = "AWS region"
}

variable "client" {
  description = "Client name (client-name)"
}

variable "prefix" {
  default     = "pam"
  description = "Prefix for pam"
}

locals {
  resource_prefix = "${var.prefix}-${var.client}"
}
