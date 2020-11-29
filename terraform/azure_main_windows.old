provider "azurerm" {
  features {}
}

variable "ImageId" {
    description = "Image ID"
    default = ""
}

variable "ImageName" {
    description = "Image name"
    default = ""
}

variable "AWS_ACCESS_KEY_ID" {
    description = "AWS Creds"
    default = ""
}

variable "AWS_SECRET_ACCESS_KEY" {
    description = "AWS Creds"
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

resource "random_string" "random" {
  length = 16
}

resource "aws_ssm_parameter" "test" {
  name  = "/builds/azure/t${local.timestamp_sanitized}/test"
  type  = "String"
  value = random_string.random.result
  overwrite   = "true"
}

resource "aws_ssm_parameter" "secret" {
  name        = "/builds/azure/t${local.timestamp_sanitized}/password"
  description = "The parameter description"
  type        = "SecureString"
  value       = random_string.random.result
  overwrite   = "true"

  tags = {
    environment = "testing"
  }
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "eastus"
}

resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "example" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_F8s_v2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  source_image_id = var.ImageId
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

}