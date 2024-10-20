output "azure_ip_addr" {
  value = azurerm_linux_virtual_machine.brainy_resource.public_ip_address
}
output "azure_ip_addrress" {
  value = azurerm_linux_virtual_machine.sapphire.public_ip_address
}

