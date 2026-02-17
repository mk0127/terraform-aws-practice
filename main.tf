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

# ------------------------------
# Route table for private subnets
# ------------------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-rt-private"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

# ------------------------------
# Security Group for Interface VPC Endpoints
# ------------------------------
resource "aws_security_group" "vpce" {
  name        = "${var.project_name}-sg-vpce"
  description = "Security group for Interface VPC Endpoints"
  vpc_id      = aws_vpc.main.id

  # Allow HTTPS from within VPC (simple & safe for now)
  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "HTTPS to VPC only"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name        = "${var.project_name}-sg-vpce"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ------------------------------
# VPC Endpoints (Interface: ECR/Logs)
# ------------------------------
locals {
  interface_vpce_services = {
    ecr_api = "com.amazonaws.${var.aws_region}.ecr.api"
    ecr_dkr = "com.amazonaws.${var.aws_region}.ecr.dkr"
    logs    = "com.amazonaws.${var.aws_region}.logs"
  }
}

resource "aws_vpc_endpoint" "interface" {
  for_each = local.interface_vpce_services

  vpc_id              = aws_vpc.main.id
  service_name        = each.value
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids         = [for s in aws_subnet.private : s.id]
  security_group_ids = [aws_security_group.vpce.id]

  tags = {
    Name        = "${var.project_name}-vpce-${each.key}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ------------------------------
# VPC Endpoint (Gateway: S3)
# ------------------------------
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [aws_route_table.private.id]

  tags = {
    Name        = "${var.project_name}-vpce-s3"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
