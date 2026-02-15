output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "Private subnet IDs (one per AZ)"
  value       = [for s in aws_subnet.private : s.id]
}

output "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks (one per AZ)"
  value       = [for s in aws_subnet.private : s.cidr_block]
}
