variable "custom_image_name" {
  type = "string"
  default = "ubuntu16PackImage"
}
variable "location" {
  type = "string"
  default = "eastus"
}
variable "custom_image_resource_group_name" {
  type = "string"
  default = "myResourceGroup"
}
variable "prefix" {
  type = "string"
  default = "test"
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