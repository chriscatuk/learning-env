output "private_ip" {
  value = var.enabled ? aws_instance.instance[0].private_ip : ""
}

output "public_ip" {
  value = var.enabled && var.public_ip ? aws_eip.ip[0].public_ip : ""
}

output "id" {
  value = var.enabled ? aws_instance.instance[0].id : ""
}

output "ipv6_address" {
  value = var.enabled ? aws_instance.instance[0].ipv6_addresses : [""]
}

output "hostname" {
  value = var.enabled && var.public_ip ? var.hostname : ""
}

output "internal_hostname" {
  value = var.enabled ? "internal-${var.hostname}" : ""
}


output "primary_network_interface_id" {
  value = var.enabled ? aws_instance.instance[0].primary_network_interface_id : ""
}
