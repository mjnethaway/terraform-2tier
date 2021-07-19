output "bastion" {
  description = "Bastion server IP"
  value       = aws_instance.app[0].public_ip
}

output "app_servers" {
  description = "App server IPs"
  value       = tomap({
    for index, instance in aws_instance.app:
          index => instance.public_ip
  })
}

output "db_servers" {
  description = "DB server IPs"
  value       = tomap({
    for index, instance in aws_instance.db:
          index => instance.private_ip
  })
}

output "proxy_servers" {
  description = "Proxy server IPs"
  value       = tomap({
    for index, instance in aws_instance.proxy:
          index => instance.public_ip
  })
}