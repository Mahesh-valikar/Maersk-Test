provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "maersk_test_rg" {
  name     = "Mahesh_Valikar"
  location = "West Europe"
}

resource "azurerm_network_security_group" "maersk_test_sg" {
  name                = "maersktestmahesh"
  location            = azurerm_resource_group.maersk_test_rg.location
  resource_group_name = azurerm_resource_group.maersk_test_rg.name
}
resource "azurerm_network_security_rule" "port80_rule" {
  name                        = "port80"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.maersk_test_rg.name
  network_security_group_name = azurerm_network_security_group.maersk_test_sg.name
}
resource "azurerm_network_security_rule" "port443_rule" {
  name                        = "port443"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.maersk_test_rg.name
  network_security_group_name = azurerm_network_security_group.maersk_test_sg.name
}

resource "azurerm_virtual_network" "maersk_test_vnt" {
  name                = "DevVnet1"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.maersk_test_rg.location
  resource_group_name = azurerm_resource_group.maersk_test_rg.name
}

resource "azurerm_subnet" "maersktestsubnet1" {
  name                 = "DevVnet1"
  resource_group_name  = azurerm_resource_group.maersk_test_rg.name
  virtual_network_name = azurerm_virtual_network.maersk_test_vnt.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "maersktestsubnet2" {
  name                 = "DevVnet2"
  resource_group_name  = azurerm_resource_group.maersk_test_rg.name
  virtual_network_name = azurerm_virtual_network.maersk_test_vnt.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "maersktest_nic1" {
  name                = "maersktest_nic1"
  location            = azurerm_resource_group.maersk_test_rg.location
  resource_group_name = azurerm_resource_group.maersk_test_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.maersktestsubnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "maersktest_nic2" {
  name                = "maersktest_nic1"
  location            = azurerm_resource_group.maersk_test_rg.location
  resource_group_name = azurerm_resource_group.maersk_test_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.maersktestsubnet2.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "maersktestvm1" {
  name                = "maersktest-machine-1"
  resource_group_name = azurerm_resource_group.maersk_test_rg.name
  location            = azurerm_resource_group.maersk_test_rg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.maersktest_nic1.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_windows_virtual_machine" "maersktestvm2" {
  name                = "maersktest-machine-1"
  resource_group_name = azurerm_resource_group.maersk_test_rg.name
  location            = azurerm_resource_group.maersk_test_rg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.maersktest_nic2.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}


resource "azurerm_storage_account" "maersktestsa" {
  name                     = "maersktestsa"
  resource_group_name      = azurerm_resource_group.maersk_test_rg.name
  location                 = azurerm_resource_group.maersk_test_rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}


data "azurerm_key_vault_secret" "maersktestusername" {
  name         = "username"
  key_vault_id = data.azurerm_key_vault.maersktestkv.id
}

output "username" {
  value = data.azurerm_key_vault_secret.maersktestkv.value
}