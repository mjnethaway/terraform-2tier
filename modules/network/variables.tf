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

variable "aws_availability_zones" {
  description = "AWS AZs"
  default     = {
    0 = {
      public_subnet = "10.0.10.0/24"
      private_subnet = "10.0.20.0/24"
      az = "ap-southeast-1a"
    }
    1 = {
      public_subnet = "10.0.11.0/24"
      private_subnet = "10.0.21.0/24"
      az = "ap-southeast-1b"
    }
  }
}

variable "public_subnets" {
  description = "AWS public subnet CIDR"
  default     = { 0 = "10.0.10.0/24", 1 = "10.0.11.0/24"}
}