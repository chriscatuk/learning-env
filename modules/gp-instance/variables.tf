# Defines the Vars for the whole project
# You should defines your own values in terraform.tfvars (example in terraform.tfvars.example)

variable "region" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "sg_ids" {
  type    = list(any)
  default = []
}

#This hostname will be setup in Linux and added to Route 53 DNS Names
#Should be FQDN, ex: vpn-test.domain.com
variable "hostname" {
  type = string
}

variable "route53_zoneID" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "template_path" {
  type    = string
  default = ""
}

variable "template_vars" {
  type    = map(string)
  default = {}
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
variable "tags" { #Possible values are ON/OFF, ON="must not be stopped by cost saving scripts"
  type = map(string)
}

variable "dnsupdate_rolearn" {
  type = string
}

variable "dnsupdate_region" {
  type = string
}

variable "enabled" {
  type    = bool
  default = true
}

variable "public_ip" {
  type    = bool
  default = false
}

variable "volume_size" {
  type    = string
  default = 10
}
