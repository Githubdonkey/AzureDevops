provider "azurerm" {
  version = "= 2.0.0"
  features {}
}

variable "image_id" {
    description = "Image name"
    default = ""
}

variable "location" {
    description = "location of image"
    default = "eastus"
}

#declare local
locals {
  timestamp = "${timestamp()}"
  timestamp_sanitized = "${replace("${local.timestamp}", "/[- TZ:]/", "")}"
}

resource "azurerm_resource_group" "rg" {
  name = "rg-${local.timestamp_sanitized}"
  location = var.location
}

resource "azurerm_virtual_network" "myvnet" {
  name = "vnet-${local.timestamp_sanitized}"
  address_space = ["10.0.0.0/16"]
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "frontendsubnet" {
  name = "frontendSubnet"
  resource_group_name =  azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.myvnet.name
  address_prefix = "10.0.1.0/24"
}

resource "azurerm_public_ip" "myvm1publicip" {
  name = "pip1"
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method = "Dynamic"
  sku = "Basic"
}

resource "azurerm_network_interface" "myvm1nic" {
  name = "nic-${local.timestamp_sanitized}"
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name = "ipconfig-${local.timestamp_sanitized}"
    subnet_id = azurerm_subnet.frontendsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.myvm1publicip.id
  }
}

resource "azurerm_windows_virtual_machine" "example" {
  name                  = "t${local.timestamp_sanitized}"  
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.myvm1nic.id]
  size                  = "Standard_F8s_v2"
  admin_username        = "adminuser"
  admin_password        = "Password123!"

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_disk {
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}