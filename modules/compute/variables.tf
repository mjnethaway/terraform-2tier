variable "default_tags" {
  default = {
    owner = "owner"
    project = "project"
    purpose = "purpose"
    environment = "environment"
  }
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "ap-southeast-1"
}

variable "prefix" {
  description = "Prefix to app server name"
  default     = "sn-"
}

# App servers
variable "app_count" {
  description = "Number of application servers"
  default     = "2"
}

variable "app_instance_type" {
  description = "EC2 Instance type"
  default     = "t2.micro"
}

# DB Servers
variable "db_count" {
  description = "Number of database servers"
  default     = "2"
}

variable "db_instance_type" {
  description = "EC2 Instance type"
  default     = "t2.micro"
}

# Proxy servers
variable "proxy_count" {
  description = "Number of proxy servers"
  default     = "2"
}

variable "proxy_instance_type" {
  description = "EC2 Instance type"
  default     = "t2.micro"
}

variable "ec2_ami" {
  description = "Launch AMI"
  default     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# REQUIRED
variable "public_subnets" {
  description = "List of Public Subnet IDs"
}

variable "private_subnets" {
  description = "List of Public Subnet IDs"
}

variable "vpc_id" {
  description = "Target VPC ID"
}

variable "ssh-key" {
  description = "ssh-key"
  default     = "ansible"
}

variable "ssh_location" {
  description = "SSH Location"
}