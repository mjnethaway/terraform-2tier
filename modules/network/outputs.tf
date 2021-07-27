# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.default.id
}

# Subnets
output "private_subnets" {
  description = "List of IDs of private subnets"
    value       = tomap({
    for index, subnet in aws_subnet.private:
          index => subnet.id
  })
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = tomap({
    for index, subnet in aws_subnet.public:
          index => subnet.id
  })
}

# Security Groups
output "securitygroup_private" {
  description = "Security group with vpc access"
  value       = aws_security_group.private
}

output "securitygroup_public" {
  description = "Security group with public access"
  value       = aws_security_group.private
}