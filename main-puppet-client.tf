module "puppet-client" {
  source = "./modules/gp-instance"

  enabled = var.puppet

  subnet_id         = aws_subnet.a.id
  sg_ids            = [aws_default_security_group.sg.id, aws_security_group.puppet-client.id]
  region            = var.region
  hostname          = "puppet-client-${var.suffix_hostname}"
  route53_zoneID    = var.route53_zoneID
  dnsupdate_rolearn = var.dnsupdate_rolearn
  dnsupdate_region  = var.dnsupdate_region
  public_ip         = true
  instance_type     = "t3.small"
  template_path     = "${path.module}/templates/puppet-client-user_data.tpl"
  template_vars = {
    hostname        = module.puppet-client.hostname
    keypubic        = var.keypublic
    username        = var.username
    master_hostname = module.puppet-server.hostname
  }

  ipv6     = var.ipv6
  username = var.username

  keypublic = var.keypublic

  tags = {
    Name        = "${var.vpcname}-puppet-client"
    environment = var.environment
    deployment  = var.deployment
    OWNER       = var.OWNER
    ROLE        = var.ROLE
    AlwaysOn    = var.AlwaysOn
  }
}

# Final Output summarising VPN Credentials, IP Addresses and DNS Names

output "Puppet_Client_Hostname" {
  #  sensitive = true
  value = var.puppet ? module.puppet-client.internal_hostname : ""
}

########################
#    SECURITY GROUP    #
########################
resource "aws_security_group" "puppet-client" {

  vpc_id      = aws_vpc.vpc.id
  name        = "${var.vpcname}_puppet-client"
  description = "${var.vpcname} puppet client"

  egress {
    from_port       = 8140
    to_port         = 8140
    protocol        = "tcp"
    security_groups = [aws_security_group.puppet-server.id]
  }

  tags = {
    Name        = "${var.vpcname}_puppet-client"
    environment = var.environment
    deployment  = var.deployment
    OWNER       = var.OWNER
    ROLE        = var.ROLE
    AlwaysOn    = var.AlwaysOn
  }
}
