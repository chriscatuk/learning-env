# Final Output summarising VPN Credentials, IP Addresses and DNS Names

output "Bastion_Hostname" {
  #  sensitive = true
  value = module.vpn-bastion.hostname
}

output "minikube_Hostname" {
  #  sensitive = true
  value = module.minikube.hostname
}

