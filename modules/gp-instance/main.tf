resource "aws_instance" "instance" {
  count         = var.enabled ? 1 : 0
  ami           = data.aws_ami.ami_amzn2.id
  instance_type = var.instance_type
  # # Removed. It was limited to RSA Keys.
  # # Replaced by Key directly in user_data
  # key_name                    = aws_key_pair.key.key_name
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.public_ip
  ipv6_address_count          = var.ipv6 != "" ? 1 : 0
  vpc_security_group_ids      = var.sg_ids
  tags                        = var.tags
  lifecycle {
    create_before_destroy = true
  }
  credit_specification {
    cpu_credits = "standard"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = var.volume_size
  }

  user_data = data.template_file.user_data.rendered
}

data "template_file" "user_data" {
  template = file(local.template_path)
  vars     = local.template_vars
}

########################
#          AMI         #
########################

# Latest AMI for Amazon Linux 2 in this region
# 31/07/2018: amzn2-ami-hvm-2.0.20180622.1-x86_64-gp2

data "aws_ami" "ami_amzn2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

########################
#      ELASTIC IP      #
########################
resource "aws_eip" "ip" {
  count    = var.enabled && var.public_ip ? 1 : 0
  instance = aws_instance.instance[0].id
  tags     = var.tags
}

# Define the Key Pair you will add in AWS
# It must not exist before running the script

########################
#       Key Pair       #
########################
# # Removed. It was limited to RSA Keys.
# # Replaced by Key directly in user_data
# resource "aws_key_pair" "key" {
#   key_name   = var.keyname
#   public_key = var.keypublic
# }

########################
#       DNS NAME       #
########################

# You can remove this file if you don't want to use DNS Names
provider "aws" {
  alias   = "dnsupdate"
  version = "> 4.0"
  assume_role {
    role_arn = var.dnsupdate_rolearn
  }
  region = var.dnsupdate_region
}

terraform {
  required_version = ">=1.1"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.0"
      configuration_aliases = [aws.dnsupdate]
    }
  }
}


resource "aws_route53_record" "servername_ipv4" {
  count    = var.enabled && var.public_ip ? 1 : 0
  provider = aws.dnsupdate
  zone_id  = var.route53_zoneID
  name     = "${var.hostname}."
  type     = "A"
  ttl      = "60"
  records  = [aws_eip.ip[0].public_ip]
}

resource "aws_route53_record" "servername_ipv4_internal" {
  count    = var.enabled ? 1 : 0
  provider = aws.dnsupdate
  zone_id  = var.route53_zoneID
  name     = "internal-${var.hostname}."
  type     = "A"
  ttl      = "60"
  records  = [aws_instance.instance[0].private_ip]
}

resource "aws_route53_record" "servername_ipv6" {
  count    = var.enabled ? 1 : 0
  provider = aws.dnsupdate
  zone_id  = var.route53_zoneID
  name     = "${var.hostname}."
  type     = "AAAA"
  ttl      = "60"
  records  = aws_instance.instance[0].ipv6_addresses
}

