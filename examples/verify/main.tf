terraform {
  required_version = ">= 0.11"
}

locals {
  out = "${var.var1}-${var.var2}"
}

resource "local_file" "foo" {
    content     = "${local.out}"
    filename = "${path.module}/foo.bar"
}

