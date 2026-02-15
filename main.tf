resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Get available AZs in the region (dynamic)
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # Balance approach:
  # - dynamic AZ discovery
  # - but fix usage to first 2 AZs for operational simplicity
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  # Create a map like:
  # {
  #   "ap-northeast-1a" = 0
  #   "ap-northeast-1c" = 1
  # }
  az_index = { for idx, az in local.azs : az => idx }
}

resource "aws_subnet" "private" {
  for_each = local.az_index

  vpc_id            = aws_vpc.main.id
  availability_zone = each.key

  # cidrsubnet(vpc_cidr, newbits, netnum)
  # netnum is 0,1,... based on AZ index
  cidr_block = cidrsubnet(var.vpc_cidr, var.private_subnet_newbits, each.value)

  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.project_name}-private-${each.key}"
    Environment = var.environment
    Tier        = "private"
    ManagedBy   = "Terraform"
  }
}
