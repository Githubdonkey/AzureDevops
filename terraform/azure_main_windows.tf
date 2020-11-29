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
  timestamp = timestamp()
  timestamp_sanitized = replace(local.timestamp, "/[- TZ:]/", "")
}

data "aws_ssm_parameter" "tf" {
  name = "/builds/terraform/default_password"
}

data "azurerm_resource_group" "build" {
  name = "AnsibleVM"
}

data "azurerm_subnet" "AnsibleSubNet" {
  name                 = "AnsibleSubNet"
  virtual_network_name = "AnsibleVnet"
  resource_group_name  = data.azurerm_resource_group.build.name
}

resource "azurerm_public_ip" "myvm1publicip" {
  name = "pip1-${local.timestamp_sanitized}"
  location = var.location
  resource_group_name = data.azurerm_resource_group.build.name
  allocation_method = "Dynamic"
  sku = "Basic"
}

resource "azurerm_network_interface" "myvm1nic" {
  name = "nic-${local.timestamp_sanitized}"
  location = var.location
  resource_group_name = data.azurerm_resource_group.build.name

  ip_configuration {
    name = "ipconfig-${local.timestamp_sanitized}"
    subnet_id = data.azurerm_subnet.AnsibleSubNet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.myvm1publicip.id
  }
}

resource "azurerm_virtual_machine" "example" {
  name                  = "t${local.timestamp_sanitized}"  
  location              = var.location
  resource_group_name   = data.azurerm_resource_group.build.name
  network_interface_ids = [azurerm_network_interface.myvm1nic.id]
  vm_size               = "Standard_A2_v2"
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
  os_profile_windows_config {
    provision_vm_agent = true
  }

  os_profile {
    computer_name  = "t${local.timestamp_sanitized}"
    admin_username = "localadm"
    admin_password = data.aws_ssm_parameter.tf.value
  }

}

output "ImageId" {value = var.ImageId}
output "ImageName" {value = var.ImageName}
output "resourceGroupId" {value = data.azurerm_resource_group.build.id}
output "publicIP" {value = azurerm_public_ip.myvm1publicip.id}