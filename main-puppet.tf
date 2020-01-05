module "puppet-server" {
  source = "./modules/gp-instance"

  enabled = var.puppet

  subnet_id         = aws_subnet.a.id
  sg_ids            = [aws_default_security_group.sg.id, aws_security_group.puppet-server.id]
  region            = var.region
  hostname          = "puppet-server-${var.suffix_hostname}"
  route53_zoneID    = var.route53_zoneID
  dnsupdate_rolearn = var.dnsupdate_rolearn
  dnsupdate_region  = var.dnsupdate_region
  instance_type     = "t3.small"
  template_path     = "${path.module}/templates/puppet-server-user_data.tpl"
  template_vars = {
    hostname = module.puppet-server.hostname
    keypubic = var.keypublic
    username = var.username
  }

  ipv6     = var.ipv6
  username = var.username

  keypublic = var.keypublic

  tags = {
    Name        = "${var.vpcname}-puppet-server"
    environment = var.environment
    deployment  = var.deployment
    OWNER       = var.OWNER
    ROLE        = var.ROLE
    AlwaysOn    = var.AlwaysOn
  }
}

# Final Output summarising VPN Credentials, IP Addresses and DNS Names

output "Puppet_Hostname" {
  #  sensitive = true
  value = var.puppet ? module.puppet-server.hostname : ""
}

########################
#    SECURITY GROUP    #
########################
resource "aws_security_group" "puppet-server" {

  vpc_id      = aws_vpc.vpc.id
  name        = "${var.vpcname}_puppet-server"
  description = "${var.vpcname} puppet server"

  ingress {
    from_port        = 8140
    to_port          = 8140
    protocol         = "tcp"
    cidr_blocks      = var.fw_app_cidr_ipv4
    ipv6_cidr_blocks = var.fw_app_cidr_ipv6
  }

  tags = {
    Name        = "${var.vpcname}_puppet-server"
    environment = var.environment
    deployment  = var.deployment
    OWNER       = var.OWNER
    ROLE        = var.ROLE
    AlwaysOn    = var.AlwaysOn
  }
}
