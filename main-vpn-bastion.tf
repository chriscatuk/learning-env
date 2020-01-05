module "vpn-bastion" {
  source = "./modules/gp-instance"

  enabled = var.vpn_bastion

  subnet_id         = aws_subnet.a.id
  sg_ids            = [aws_security_group.sg_bastion.id, aws_security_group.vpn.id]
  region            = var.region
  hostname          = "training-bastion-${var.suffix_hostname}"
  route53_zoneID    = var.route53_zoneID
  dnsupdate_rolearn = var.dnsupdate_rolearn
  dnsupdate_region  = var.dnsupdate_region
  instance_type     = var.instance_type
  template_path     = "${path.module}/templates/vpn-server-user_data.tpl"
  template_vars = {
    hostname = module.vpn-bastion.hostname
    password = random_string.password.result
    psk      = random_string.PSK.result
    keypubic = var.keypublic
    username = var.username
  }

  ipv6     = var.ipv6
  username = var.username

  keypublic = var.keypublic

  tags = {
    Name        = "${var.vpcname}-bastion"
    environment = var.environment
    deployment  = var.deployment
    OWNER       = var.OWNER
    ROLE        = var.ROLE
    AlwaysOn    = var.AlwaysOn
  }
}

########################
#    VPN CREDENTIALS   #
########################
# Usage: ${random_string.password.result}
resource "random_string" "password" {
  length  = 16
  special = false
}

resource "random_string" "PSK" {
  length  = 16
  special = false
}

output "VPN-Credentials" {
  #  sensitive = true
  value = var.vpn_bastion ? "Server: ${module.vpn-bastion.hostname} - PSK: ${random_string.PSK.result} - User: vpnuser / ${random_string.password.result} \n Internal: ${module.vpn-bastion.internal_hostname}" : ""
}

########################
#    SECURITY GROUP    #
########################
resource "aws_security_group" "vpn" {

  vpc_id      = aws_vpc.vpc.id
  name        = "${var.vpcname}_vpn"
  description = "${var.vpcname} vpn-bastion vpn access"

  ingress {
    from_port        = 500
    to_port          = 500
    protocol         = "udp"
    cidr_blocks      = var.fw_vpn_cidr_ipv4
    ipv6_cidr_blocks = var.fw_vpn_cidr_ipv6
  }

  ingress {
    from_port        = 4500
    to_port          = 4500
    protocol         = "udp"
    cidr_blocks      = var.fw_vpn_cidr_ipv4
    ipv6_cidr_blocks = var.fw_vpn_cidr_ipv6
  }

  tags = {
    Name        = "${var.vpcname}_vpn"
    environment = var.environment
    deployment  = var.deployment
    OWNER       = var.OWNER
    ROLE        = var.ROLE
    AlwaysOn    = var.AlwaysOn
  }
}
