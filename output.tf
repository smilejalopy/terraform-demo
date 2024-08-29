output "public_ip_address" {
  value = azurerm_public_ip.pip1.ip_address
}

output "vm_password" {
    sensitive = true
    value = azurerm_windows_virtual_machine.vm1.admin_password
}