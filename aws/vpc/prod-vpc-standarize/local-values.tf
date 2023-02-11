locals {
  owners = var.business_divison
  environment = var.environment
  name = "${var.business_divison}-${var.environment}"
#   name = "${local.owners}-${local.environment}"
  common_tags = {
    owners = local.owners
    environment = local.environment
  }
}