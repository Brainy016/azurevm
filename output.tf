output "azure_ip_addr" {
  value = azurerm_linux_virtual_machine.brainy_resource.public_ip_address
}
