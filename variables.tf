variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev/stg/prod)"
  type        = string
}

variable "az_count" {
  description = "Number of Availability Zones to use (fixed to 2 for this project)"
  type        = number
  default     = 2

  validation {
    condition     = var.az_count == 2
    error_message = "This project fixes az_count to 2 to keep the architecture simple and finance-friendly."
  }
}

variable "private_subnet_newbits" {
  description = "Additional bits to split VPC CIDR for private subnets. /16 + 8 => /24"
  type        = number
  default     = 8
}

variable "db_engine" {
  description = "Database engine"
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "8.0"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 3306
}