module "jenkins-server" {
  source = "./modules/gp-instance"

  subnet_id         = aws_subnet.a.id
  sg_id             = aws_default_security_group.sg.id
  region            = var.region
  hostname          = "jenkins-server-${var.suffix_hostname}"
  route53_zoneID    = var.route53_zoneID
  dnsupdate_rolearn = var.dnsupdate_rolearn
  dnsupdate_region  = var.dnsupdate_region
  instance_type     = "t3.small"
  template_path     = "${path.module}/templates/jenkins-server-user_data.tpl"
  template_vars = {
    hostname = module.jenkins-server.hostname
    keypubic = var.keypublic
    username = var.username
  }

  ipv6     = var.ipv6
  username = var.username

  keypublic = var.keypublic

  tags = {
    Name        = "${var.vpcname}-jenkins-server"
    environment = var.environment
    deployment  = var.deployment
    OWNER       = var.OWNER
    ROLE        = var.ROLE
    AlwaysOn    = var.AlwaysOn
  }
}

# Final Output summarising VPN Credentials, IP Addresses and DNS Names

output "Jenkins_Hostname" {
  #  sensitive = true
  value = module.jenkins-server.hostname
}

module "jenkins-worker" {
  source = "./modules/gp-instance"

  subnet_id         = aws_subnet.a.id
  sg_id             = aws_default_security_group.sg.id
  region            = var.region
  hostname          = "jenkins-worker-${var.suffix_hostname}"
  route53_zoneID    = var.route53_zoneID
  dnsupdate_rolearn = var.dnsupdate_rolearn
  dnsupdate_region  = var.dnsupdate_region
  instance_type     = "t3.micro"
  template_path     = "${path.module}/templates/jenkins-client-user_data.tpl"
  template_vars = {
    hostname        = module.jenkins-worker.hostname
    keypubic        = var.keypublic
    username        = var.username
    master_hostname = module.jenkins-server.hostname
  }

  ipv6     = var.ipv6
  username = var.username

  keypublic = var.keypublic

  tags = {
    Name        = "${var.vpcname}-jenkins-worker"
    environment = var.environment
    deployment  = var.deployment
    OWNER       = var.OWNER
    ROLE        = var.ROLE
    AlwaysOn    = var.AlwaysOn
  }

}

output "Jenkins_Worker_Hostname" {
  #  sensitive = true
  value = module.jenkins-worker.hostname
}

########################
#    SECURITY GROUP    #
########################
resource "aws_security_group" "jenkins-server" {
  vpc_id      = aws_vpc.vpc.id
  name        = "${var.vpcname}_jenkins-server"
  description = "${var.vpcname} jenkins server"

  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = var.fw_app_cidr_ipv4
    ipv6_cidr_blocks = var.fw_app_cidr_ipv6
  }

  ingress {
    from_port        = 50000
    to_port          = 50000
    protocol         = "udp"
    cidr_blocks      = var.fw_app_cidr_ipv4
    ipv6_cidr_blocks = var.fw_app_cidr_ipv6
  }

  tags = {
    Name        = var.vpcname
    environment = var.environment
    deployment  = var.deployment
    OWNER       = var.OWNER
    ROLE        = var.ROLE
    AlwaysOn    = var.AlwaysOn
  }
}

resource "aws_network_interface_sg_attachment" "jenkins-server_sg_attachment" {
  security_group_id    = aws_security_group.jenkins-server.id
  network_interface_id = module.jenkins-server.primary_network_interface_id
}
