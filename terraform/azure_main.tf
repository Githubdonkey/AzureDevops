variable "aws_builder" {
  type = "string"
  default = ""
}
variable "azure_builder" {
  type = "string"
  default = ""
}
variable "custom_image_name" {
  type = "string"
  default = ""
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
variable "packer_image" {
  type = "string"
}

variable "google_vpc_cidr" {
    description = "Google Compute Engine VPC CIDR"
    default = ""
}

resource "aws_security_group" "queue" {
    name = "queue"
    description = "Queue role"
}

resource "aws_security_group_rule" "rabbitmq_tcp_5672_google" {
    count = "${var.google_vpc_cidr != "" ? 1 : 0}"

    type = "ingress"
    from_port = 5672
    to_port = 5672
    protocol = "tcp"
    cidr_blocks = [
       "${var.google_vpc_cidr}"
    ]
    security_group_id = "${aws_security_group.queue.id}"
}


provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = "=1.38.0"
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
  name                = "${var.packer_image}"
  resource_group_name = "${var.custom_image_resource_group_name}"
}

#output "image_id" {
#  value = "${data.azurerm_image.search.id}"
#}

resource "azurerm_virtual_machine" "example" {
  name                  = "${var.custom_image_name}-${local.timestamp_sanitized}"
  location              = "${data.azurerm_resource_group.example.location}"
  resource_group_name   = "${data.azurerm_resource_group.example.name}"
  network_interface_ids = ["${data.azurerm_network_interface.example.id}"]
  vm_size               = "Standard_F2"

  # This means the OS Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_os_disk_on_termination = true

  # This means the Data Disk Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_data_disks_on_termination = true

  storage_image_reference {
    id="${data.azurerm_image.search.id}"
  }

  storage_os_disk {
    name              = "os_${var.custom_image_name}"
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
