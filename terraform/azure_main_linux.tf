provider "azurerm" {
  version = "= 2.0.0"
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

variable "location" {
    description = "location of image"
    default = "eastus"
}

variable "custom_image_resource_group_name" {
  description = "location of image rg"
  default = "myResourceGroup"
}

#declare local
locals {
  timestamp = "${timestamp()}"
  timestamp_sanitized = "${replace("${local.timestamp}", "/[- TZ:]/", "")}"
}

data "aws_ssm_parameter" "tf" {
  name = "/builds/terraform/default_password"
}

resource "random_string" "random" {
  length = 16
  special = true
  override_special = "/@£$"
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

resource "azurerm_virtual_machine" "example" {
  name                  = "t${local.timestamp_sanitized}"  
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.myvm1nic.id]
  vm_size               = "Standard_F8s_v2"
  tags = {
    tfState = "s3://gitdonkey/devops/${var.ImageName}-${local.timestamp_sanitized}.tfstate"
  }


  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    id = var.ImageId
  }

  storage_os_disk {
    name              = "t${local.timestamp_sanitized}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "t${local.timestamp_sanitized}"
    admin_username = "testadmin"
    admin_password = data.aws_ssm_parameter.tf.value
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

output "ImageId" {
  value = var.ImageId
}

output "ImageName" {
  value = var.ImageName
}