provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = "=1.38.0"
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
  #location            = "${data.azurerm_resource_group.example.location}"
  resource_group_name = "${data.azurerm_resource_group.example.name}"

  #ip_configuration {
   # name                          = "testconfiguration1"
   # subnet_id                     = "${data.azurerm_subnet.example.id}"
   # private_ip_address_allocation = "Dynamic"
  #}
}

resource "azurerm_virtual_machine" "example" {
  name                  = "${var.custom_image_name}"
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
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
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
