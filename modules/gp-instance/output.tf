output "private_ip" {
  value = aws_instance.instance.private_ip
}

output "public_ip" {
  value = aws_eip.ip.public_ip
}

output "id" {
  value = aws_instance.instance.id
}

output "ipv6_address" {
  value = aws_instance.instance.ipv6_addresses
}

output "aws_console_link" {
  value = "https://${var.region}.console.aws.amazon.com/ec2/v2/home?region=${var.region}#Instances:instanceId=${aws_instance.instance.id};sort=desc:instanceId"
}

output "hostname" {
  value = var.hostname
}

output "internal_hostname" {
  value = "internal-${var.hostname}"
}


output "primary_network_interface_id" {
  value = aws_instance.instance.primary_network_interface_id
}
