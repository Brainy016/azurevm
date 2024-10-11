data "azurerm_ssh_public_key" "vm_key" {
  name                = "terraformkey"
  resource_group_name = "Jenkins_group"
}

resource "azurerm_resource_group" "brainy_resource" {
  name     = "brainy_resource-resources"
  location = "West Europe"
}

resource "azurerm_public_ip" "example" {
  name                = "acceptanceTestPublicIp1"
  resource_group_name = azurerm_resource_group.brainy_resource.name
  location            = azurerm_resource_group.brainy_resource.location
  allocation_method   = "Static"

  
}
resource "azurerm_virtual_network" "brainy_resource" {
  name                = "brainy_resource-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.brainy_resource.location
  resource_group_name = azurerm_resource_group.brainy_resource.name
}

resource "azurerm_subnet" "brainy_resource" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.brainy_resource.name
  virtual_network_name = azurerm_virtual_network.brainy_resource.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "brainy_resource" {
  name                = "brainy_resource-nic"
  location            = azurerm_resource_group.brainy_resource.location
  resource_group_name = azurerm_resource_group.brainy_resource.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.brainy_resource.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "brainy_resource" {
  name                = "First-vm"
  resource_group_name = azurerm_resource_group.brainy_resource.name
  location            = azurerm_resource_group.brainy_resource.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.brainy_resource.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = data.azurerm_ssh_public_key.vm_key.public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}