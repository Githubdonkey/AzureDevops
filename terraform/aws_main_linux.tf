provider "aws" {
  version = "~> 2.7"
  region  = "us-east-1"
}

variable "ImageId" {}

variable "ImageName" {}

resource "aws_instance" "secOps" {
  ami = var.ImageId
  instance_type = "t2.2xlarge"

  tags = {
    Name = var.ImageName
    Source_image = var.ImageId
  }
}

# count = var.createInstanceLinux ? 1 : 0