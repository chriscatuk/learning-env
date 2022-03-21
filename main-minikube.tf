module "minikube" {
  source = "./modules/gp-instance"

  enabled = var.minikube

  subnet_id         = aws_subnet.a.id
  sg_ids            = [aws_default_security_group.sg.id, aws_security_group.minikube.id]
  region            = var.region
  hostname          = "training-minikube-${var.suffix_hostname}"
  route53_zoneID    = var.route53_zoneID
  dnsupdate_rolearn = var.dnsupdate_rolearn
  dnsupdate_region  = var.dnsupdate_region
  instance_type     = "t3.medium"
  template_path     = "${path.module}/templates/minikube-user_data.tpl"
  template_vars = {
    hostname = module.minikube.hostname
    keypubic = var.keypublic
    username = var.username
  }

  ipv6        = var.ipv6
  username    = var.username
  volume_size = 50

  keypublic = var.keypublic

  tags = {
    Name        = "${var.vpcname}-minikube"
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
resource "aws_security_group" "minikube" {

  vpc_id      = aws_vpc.vpc.id
  name        = "${var.vpcname}_minikube"
  description = "${var.vpcname} minikube"

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = var.fw_ssh_cidr_ipv4
    ipv6_cidr_blocks = var.fw_ssh_cidr_ipv6
    description      = "HTTPS from home"
  }

  tags = {
    Name        = "${var.vpcname}_minikube"
    environment = var.environment
    deployment  = var.deployment
    OWNER       = var.OWNER
    ROLE        = var.ROLE
    AlwaysOn    = var.AlwaysOn
  }
}
