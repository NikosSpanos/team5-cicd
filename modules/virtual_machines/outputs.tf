output "tls_private_key" {
    value = tls_private_key.ssh_cicd.private_key_pem 
}

output "tls_public_key" {
    value = tls_private_key.ssh_cicd.public_key_pem
}

output "public_ip_address" {
  value = azurerm_public_ip.public_ip_cicd.ip_address
}