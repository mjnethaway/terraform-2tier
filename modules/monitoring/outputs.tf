# Route53
output "healthcheck_route53" {
  description = "The ID of the healthcheck"
  value       = aws_route53_health_check.route53.id
}
