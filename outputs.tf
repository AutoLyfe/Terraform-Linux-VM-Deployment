output "public_ip_address" {
  value = azurerm_public_ip.Test_PIP.ip_address
}

output "tls_private_key" {
  value     = tls_private_key.test_ssh.private_key_pem
  sensitive = true
}