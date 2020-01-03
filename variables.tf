variable "custom_image_name" {
  type = string
  default = "ubuntu16PackImage"
}
variable "location" {
  type = string
  default = "eastus"
}
variable "custom_image_resource_group_name" {
  type = string
  default = "myResourceGroup"
}
variable "prefix" {
  type = string
  default = "test"
}