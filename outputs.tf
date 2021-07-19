# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.network.vpc_id
}

### The Ansible inventory file
resource "local_file" "AnsibleInventory" {
 content = templatefile("templates/inventory.tmpl",
 {
   app = module.compute.app_servers
   db = module.compute.db_servers
   proxy = module.compute.proxy_servers
 }
 )
 filename = "outputs/hosts.ini"
}

### Create ssh config file
resource "local_file" "SSHConfig" {
 content = templatefile("templates/config.tmpl",
 {
   bastion = module.compute.bastion
   public_key_path = var.public_key_path
 }
 )
 filename = "outputs/config"
}
