# terraform init
# terraform apply -var vpcname='VPN-Test' -var ipv6=true -var region='eu-west-3'
# terraform destroy -var vpcname='VPN-Test' -var region='eu-west-3'
# Or create terraform.tfvars and use only terraform apply

########################
#    VPC CREATION      #
########################
resource "aws_vpc" "vpc" {
  cidr_block                       = var.cidr
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = var.ipv6

  tags = {
    Name        = var.vpcname
    environment = var.environment
    deployment  = var.deployment
    OWNER       = var.OWNER
    ROLE        = var.ROLE
    AlwaysOn    = var.AlwaysOn
  }
}

########################
#    IGW CREATION      #
########################
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = var.vpcname
    environment = var.environment
    deployment  = var.deployment
    OWNER       = var.OWNER
    ROLE        = var.ROLE
    AlwaysOn    = var.AlwaysOn
  }
}

########################
#   Subnets Creation   #
########################
data "aws_availability_zones" "available" {
}

resource "aws_subnet" "a" {
  availability_zone       = data.aws_availability_zones.available.names[0]
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 2, 0)
  map_public_ip_on_launch = true

  # Bug Issue 688: https://github.com/terraform-providers/terraform-provider-aws/issues/688
  # Soon set even if no IPv6 for VPC
  # https://github.com/terraform-providers/terraform-provider-aws/pull/2103
  ipv6_cidr_block                 = var.ipv6 ? cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, 8, 10) : ""
  assign_ipv6_address_on_creation = true

  tags = {
    Name        = "${var.vpcname}-a"
    environment = var.environment
    deployment  = var.deployment
    OWNER       = var.OWNER
    ROLE        = var.ROLE
    AlwaysOn    = var.AlwaysOn
  }
}

resource "aws_subnet" "b" {
  availability_zone       = data.aws_availability_zones.available.names[1]
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 2, 1)
  map_public_ip_on_launch = true

  ipv6_cidr_block                 = var.ipv6 ? cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, 8, 11) : ""
  assign_ipv6_address_on_creation = true

  tags = {
    Name        = "${var.vpcname}-b"
    environment = var.environment
    deployment  = var.deployment
    OWNER       = var.OWNER
    ROLE        = var.ROLE
    AlwaysOn    = var.AlwaysOn
  }
}

# resource "aws_subnet" "c" {
#     availability_zone = "${data.aws_availability_zones.available.names[2]}"
#     vpc_id = "${aws_vpc.vpc.id}"
#     cidr_block = "${cidrsubnet(aws_vpc.vpc.cidr_block, 2, 2)}"
#     map_public_ip_on_launch = true

#     ipv6_cidr_block = "${var.ipv6 ? cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, 8, 12) : ""}"
#     assign_ipv6_address_on_creation = true

#   tags {
#     Name = "${var.vpcname}-c"
#     environment = "${var.environment}"
#     deployment = "${var.deployment}"
#     OWNER = "${var.OWNER}"
#     ROLE = "${var.ROLE}"
#     AlwaysOn = "${var.AlwaysOn}"
#   }
# }

########################
#  Route Table Update  #
########################
resource "aws_default_route_table" "route" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
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

resource "aws_route_table_association" "route_sb_a" {
  subnet_id      = aws_subnet.a.id
  route_table_id = aws_default_route_table.route.id
}

resource "aws_route_table_association" "route_sb_b" {
  subnet_id      = aws_subnet.b.id
  route_table_id = aws_default_route_table.route.id
}

# resource "aws_route_table_association" "route_sb_c" {
#     subnet_id      = "${aws_subnet.c.id}"
#     route_table_id = "${aws_default_route_table.route.id}"
# }

###################################
#    SECURITY GROUP CREATION      #
###################################
resource "aws_default_security_group" "sg" {
  vpc_id = aws_vpc.vpc.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  tags = {
    Name        = "${var.vpcname}-default"
    environment = var.environment
    deployment  = var.deployment
    OWNER       = var.OWNER
    ROLE        = var.ROLE
    AlwaysOn    = var.AlwaysOn
  }
}

# Handle dependancies on destroy
resource "aws_security_group_rule" "ssh_jump" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg_bastion.id
  security_group_id        = aws_default_security_group.sg.id
}

###############################################
#    SECURITY GROUP TO BE USED BY CLIENTS     #
###############################################
resource "aws_security_group" "sg_bastion" {
  vpc_id      = aws_vpc.vpc.id
  name        = "${var.vpcname}_bastion"
  description = "${var.vpcname} Bastion"
  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = var.fw_ssh_cidr_ipv4
    ipv6_cidr_blocks = var.fw_ssh_cidr_ipv6
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.vpc.cidr_block]
    ipv6_cidr_blocks = var.ipv6 ? [aws_vpc.vpc.ipv6_cidr_block] : []
    description      = "same VPC"
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.vpcname}-bastion"
    environment = var.environment
    deployment  = var.deployment
    OWNER       = var.OWNER
    ROLE        = var.ROLE
    AlwaysOn    = var.AlwaysOn
  }
}
