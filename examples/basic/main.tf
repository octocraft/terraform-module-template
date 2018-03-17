terraform {
  required_version = ">= 0.11"
}

locals {
  out = "${var.var1}-${var.var2}"
}
