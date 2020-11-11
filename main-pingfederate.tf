module "pingfederate" {
  source = "./modules/gp-instance"

  enabled = var.pingfederate

  subnet_id         = aws_subnet.a.id
  sg_ids            = [aws_default_security_group.sg.id, aws_security_group.pingfederate.id]
  region            = var.region
  hostname          = "pingfederate-${var.suffix_hostname}"
  route53_zoneID    = var.route53_zoneID
  dnsupdate_rolearn = var.dnsupdate_rolearn
  dnsupdate_region  = var.dnsupdate_region
  instance_type     = "t3.large"
  template_path     = "${path.module}/templates/pingfederate-user_data.tpl"
  template_vars = {
    hostname = module.pingfederate.hostname
    keypubic = var.keypublic
    username = var.username
  }

  ipv6     = var.ipv6
  username = var.username

  keypublic = var.keypublic

  tags = {
    Name        = "${var.vpcname}-pingfederate"
    environment = var.environment
    deployment  = var.deployment
    OWNER       = var.OWNER
    ROLE        = var.ROLE
    AlwaysOn    = var.AlwaysOn
  }
}



########################
#    SECURITY GROUP    #
########################
resource "aws_security_group" "pingfederate" {

  vpc_id      = aws_vpc.vpc.id
  name        = "${var.vpcname}_pingfederate"
  description = "${var.vpcname} pingfederate"

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = var.fw_app_cidr_ipv4
    ipv6_cidr_blocks = var.fw_app_cidr_ipv6
  }

  ingress {
    from_port        = 9999
    to_port          = 9999
    protocol         = "tcp"
    cidr_blocks      = var.fw_app_cidr_ipv4
    ipv6_cidr_blocks = var.fw_app_cidr_ipv6
  }

  tags = {
    Name        = "${var.vpcname}_pingfederate"
    environment = var.environment
    deployment  = var.deployment
    OWNER       = var.OWNER
    ROLE        = var.ROLE
    AlwaysOn    = var.AlwaysOn
  }
}

output "pingfederate_Hostname" {
  #  sensitive = true
  value = var.pingfederate ? module.pingfederate.internal_hostname : ""
}
