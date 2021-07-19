# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.default.id
}

# Subnets
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = [aws_subnet.private1.id, aws_subnet.private2.id]
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = [aws_subnet.public1.id, aws_subnet.public2.id]
}

output "private_subnet1" {
  description = "A reference to the private subnet in the 1st Availability Zone"
  value       = aws_subnet.private1.id
}

output "private_subnet2" {
  description = "A reference to the private subnet in the 2nd Availability Zone"
  value       = aws_subnet.private2.id
}

output "public_subnet1" {
  description = "A reference to the public subnet in the 1st Availability Zone"
  value       = aws_subnet.public1.id
}

output "public_subnet2" {
  description = "A reference to the public subnet in the 2nd Availability Zone"
  value       = aws_subnet.public2.id
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