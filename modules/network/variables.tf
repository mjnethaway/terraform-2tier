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
