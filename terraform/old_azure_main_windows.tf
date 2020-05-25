provider "azurerm" {
  version = "= 2.0.0"
  features {}
}

variable "image_id" {
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

variable "custom_image_resource_group_name" {
  description = "location of image rg"
  default = "myResourceGroup"
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

data "azurerm_image" "search" {
  name                = var.image_id
  resource_group_name = var.custom_image_resource_group_name
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
  #depends_on=[azurerm_network_interface.web-windows-vm-nic]
  name = "t${local.timestamp_sanitized}"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name
  size                  = "Standard_F8s_v2"
  network_interface_ids = [azurerm_network_interface.myvm1nic.id]
  source_image_id = data.azurerm_image.search.id
  computer_name = "t${local.timestamp_sanitized}"
  admin_username = "localadm"
  admin_password = random_string.random.result

  os_disk {
    name              = "t${local.timestamp_sanitized}"
    caching              = "ReadWrite"
    #create_option     = "FromImage"
    storage_account_type = "Standard_LRS"
  }

  provision_vm_agent       = true

  tags = {
    environment = "testingEnviroment" 
  }
}

locals {
  aws_id ="$AWS_ACCESS_KEY_ID = ${var.AWS_ACCESS_KEY_ID}"
  aws_key ="$AWS_SECRET_ACCESS_KEY = ${var.AWS_SECRET_ACCESS_KEY}"
  awscli2_from ="$awscli2_from = 'https:\\/\\/awscli.amazonaws.com/AWSCLIV2.msi'"
  awscli2_to ="$awscli2_to = 'c:/image/AWSCLIV2.msi'"
  download_command = "Invoke-WebRequest -Uri $awscli2_from -OutFile $awscli2_to"
  download = "${local.awscli2_from}; ${local.awscli2_to}; ${local.download_command}"

  arg_command =  "$arg_command = '/I c:/image/AWSCLIV2.msi /quiet /norestart'"
  aws_command = "Start-Process msiexec -Wait -ArgumentList '/I C:/image/AWSCLIV2.msi /quiet /norestart'"
  sleep = "Start-Sleep -s 15"
  write_host = "Write-Host ${var.AWS_ACCESS_KEY_ID}"
  aws_run = "${local.awscli2_from}; ${local.awscli2_to}; ${local.download_command}; ${local.sleep}; ${local.aws_command}; ${local.write_host}"
}

# https://medium.com/@gmusumeci/how-to-bootstrapping-azure-vms-with-terraform-c8fdaa457836
# Virtual Machine Extension to Install IIS
resource "azurerm_virtual_machine_extension" "iis-windows-vm-extension" {
  depends_on=[azurerm_windows_virtual_machine.example]
  name = "t${local.timestamp_sanitized}-vm-extension"
  virtual_machine_id = azurerm_windows_virtual_machine.example.id
  publisher = "Microsoft.Compute"
  type = "CustomScriptExtension"
  type_handler_version = "1.9"
  settings = <<SETTINGS
    { 
      "commandToExecute":"powershell.exe -Command \"${local.aws_run}\""
    } 
  SETTINGS
  tags = {
     environment = "testingenviroment"
  }
}

output "image_id" {
  value = var.image_id
}

output "AWS_ACCESS_KEY_ID" {
  value = var.AWS_ACCESS_KEY_ID
}