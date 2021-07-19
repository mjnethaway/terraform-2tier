variable "default_tags" {
  default = {
    owner = "Matthew Nethaway"
    project = "sn-onprem"
    purpose = "DEVELOPMENT"
    environment = "sn-terraform"
  }
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "ap-southeast-1"
}

variable "key_name" {
  description = "Desired name of AWS key pair"
  default = "ansible"
}

variable "public_key_path" {
  description = <<DESCRIPTION
    Path to the SSH public key to be used for authentication.  Ensure this
    keypair is added to your local SSH agent so provisioners can connect.
DESCRIPTION
  default = "~/.ssh/ansible"
}

variable "ssh_location" {
  description = "Origin for SSH admin"
  default = "158.140.128.205/32"
}

variable "dns_zone_id" {
  description = "Route53 zone ID"
  default = "Z0352196UAH56GY764S8"
}

variable "fqdn" {
  description = "Domain name"
  default = "test.blipsandchitz.net"
}

