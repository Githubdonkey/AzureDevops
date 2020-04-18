provider "aws" {}

provider "azurerm" {}

variable "aws_builder" {
  default = ""
}
variable "image_id" {}

variable location {
    type = "string"
    default = "eastus"
}

variable "custom_image_name" {
  type = "string"
  default = "testit"
}
variable "custom_image_resource_group_name" {
  type = "string"
  default = "myResourceGroup"
}
variable "custom_virtual_network" {
  type = "string"
  default = "test-network"
}
variable "custom_subnet" {
  type = "string"
  default = "internal"
}
variable "custom_network_interface" {
  type = "string"
  default = "test-nic"
}

variable hostname {
    type = "string"
    default = "ora"
}

variable udfile{
    type = "string"
    default = "userdata.sh"
}

#declare local
locals {
  timestamp = "${timestamp()}"
  timestamp_sanitized = "${replace("${local.timestamp}", "/[- TZ:]/", "")}"
}

data "azurerm_resource_group" "example" {
  name     = "${var.custom_image_resource_group_name}"
}

data "azurerm_virtual_network" "example" {
  name                = "${var.custom_virtual_network}"
  resource_group_name = "${data.azurerm_resource_group.example.name}"
}

data "azurerm_subnet" "example" {
  name                 = "${var.custom_subnet}"
  resource_group_name  = "${data.azurerm_resource_group.example.name}"
  virtual_network_name = "${data.azurerm_virtual_network.example.name}"
}

data "azurerm_network_interface" "example" {
  name                = "${var.custom_network_interface}"
  resource_group_name = "${data.azurerm_resource_group.example.name}"
}
data "azurerm_image" "search" {
  name                = "${var.image_id}"
  resource_group_name = "${var.custom_image_resource_group_name}"
}

resource "azurerm_virtual_machine" "example" {
  name                  = "${data.azurerm_image.search.id}-${local.timestamp_sanitized}"
  location              = "${data.azurerm_resource_group.example.location}"
  resource_group_name   = "${data.azurerm_resource_group.example.name}"
  network_interface_ids = ["${data.azurerm_network_interface.example.id}"]
  vm_size               = "Standard_F2"

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    id="${data.azurerm_image.search.id}"
  }

  storage_os_disk {
    name              = "${data.azurerm_image.search.id}-${local.timestamp_sanitized}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
} 

resource "azurerm_virtual_machine_extension" "stage" {
    name = "CustomScript"
    location              = "${var.location}"
    resource_group_name = "${data.azurerm_resource_group.example.name}"
    virtual_machine_name = "${azurerm_virtual_machine.example.name}"
    publisher = "Microsoft.Compute"
    type = "CustomScriptExtension"
    type_handler_version = "1.9.5"
    auto_upgrade_minor_version = true

    settings = <<SETTINGS
    {
        "commandToExecute": "echo 1"
    }
SETTINGS
    depends_on = [azurerm_virtual_machine.example]
}