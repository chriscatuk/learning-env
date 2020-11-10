# Defines the Vars for the whole project
# You should defines your own values in terraform.tfvars (example in terraform.tfvars.example)

variable "region" {
  type    = string
  default = "eu-west-2"
}

#All resources will have this Name tag (VPC, SG, IGW, Subnets...)
variable "vpcname" {
  type    = string
  default = "VPC-Test"
}

#Subnet of the VPC (will be divided in 3 Availability Zones)
variable "cidr" {
  type    = string
  default = "172.30.200.0/22"
}

# Will it deploy a puppet server
variable "puppet" {
  type    = bool
  default = false
}

variable "puppet_version" { # tag in Docker Hub repo puppet/puppetserver
  type    = string
  default = "latest"
}

variable "puppetdb_version" { # tag in Docker Hub repo puppet/puppetdb
  type    = string
  default = "latest"
}

# Will it deploy a Jenkins server
variable "jenkins" {
  type    = bool
  default = false
}

# Will it deploy a Ping Federate cluster
variable "pingfederate" {
  type    = bool
  default = false
}

# Will it deploy a VPN-Bastion server
variable "vpn_bastion" {
  type    = bool
  default = true
}

#hostname will be setup in Linux and added to Route 53 DNS Names
#Should be FQDN, ex: test.domain.com
variable "suffix_hostname" {
  type = string
}

variable "route53_domain" {
  type = string
}

variable "route53_zoneID" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

# define with relative path, ${path.module} will be added
# template_path = "templates/vpn-server-user_data.tpl"
variable "template_path" {
  type    = string
  default = ""
}

# Enable IPv6 support, in Dual Stack mode
variable "ipv6" {
  type    = bool
  default = true
}

# User with SSH and Sudo access.
variable "username" {
  type = string
}

#SSH Key Pair
variable "keypublic" { # keypublic line will be added to ~/.ssh/authorized_keys
  type = string
}

# Tags of all resources
variable "deployment" {
  type    = string
  default = "terraform"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "OWNER" {
  type = string
}

variable "ROLE" {
  default = "Bastion and VPN Server compatible with iOS and MacOS native VPN Clients"
}

variable "AlwaysOn" { #Possible values are ON/OFF, ON="must not be stopped by cost saving scripts"
  type    = string
  default = "False"
}

# CIDRs allowed for VPN traffic
variable "fw_vpn_cidr_ipv4" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
variable "fw_vpn_cidr_ipv6" {
  type    = list(string)
  default = ["::/0"]
}

# CIDRs allowed for App traffic
variable "fw_app_cidr_ipv4" {
  type    = list(string)
  default = ["10.0.0.0/8"]
}
variable "fw_app_cidr_ipv6" {
  type    = list(string)
  default = ["fd00::/8"]
}

# CIDRs allowed for SSH
variable "fw_ssh_cidr_ipv4" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "fw_ssh_cidr_ipv6" {
  type    = list(string)
  default = ["::/0"]
}

variable "dnsupdate_rolearn" {
  type = string
}

variable "dnsupdate_region" {
  type = string
}
