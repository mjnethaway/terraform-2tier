provider "aws" {
  region = "${var.aws_region}"
  default_tags {
    tags = "${var.default_tags}"
  }
}

module "network" {
  source = "./modules/network"
}

module "compute" {
  source = "./modules/compute"
  public_subnets = module.network.public_subnets
  private_subnets = module.network.private_subnets
  ssh_location = var.ssh_location
  vpc_id = module.network.vpc_id
}

module "monitoring" {
  source = "./modules/monitoring"
  fqdn = var.fqdn
}

resource "aws_route53_record" "www" {
  zone_id = var.dns_zone_id
  name    = var.fqdn
  type    = "A"
  ttl     = "300"

  failover_routing_policy {
    type = "PRIMARY"
  }
  health_check_id = module.monitoring.healthcheck_route53

  set_identifier = "primary"
  records = [module.compute.proxy_servers[0]]
}

resource "aws_route53_record" "www2" {
  zone_id = var.dns_zone_id
  name    = var.fqdn
  type    = "A"
  ttl     = "300"

  failover_routing_policy {
    type = "SECONDARY"
  }

  set_identifier = "failover"
  records = [module.compute.proxy_servers[1]]
}

#TODO: Monitoring and alarms

//resource "aws_route53_health_check" "primary" {
//  fqdn              = "mineiros.io"
//  port              = 80
//  type              = "HTTP"
//  resource_path     = "/"
//  failure_threshold = 5
//  request_interval  = 30
//
//  tags = {
//    Name = "mineiros-io-primary-healthcheck"
//  }
//}
//
//module "route53" {
//  source  = "mineiros-io/route53/aws"
//  version = "~> 0.5.0"
//
//  name                         = "mineiros.io"
//  skip_delegation_set_creation = true
//
//  records = [
//    {
//      type           = "A"
//      set_identifier = "primary"
//      failover       = "PRIMARY"
//      # Non-alias primary records must have an associated health check
//      health_check_id = aws_route53_health_check.primary.id
//      records = [
//        "203.0.113.200"
//      ]
//    },
//    {
//      type            = "A"
//      set_identifier  = "failover"
//      failover        = "SECONDARY"
//      health_check_id = null
//      records = [
//        "203.0.113.201",
//        "203.0.113.202"
//      ]
//    }
//  ]
//}