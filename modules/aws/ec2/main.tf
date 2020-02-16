
provider "aws" {
  version = "~> 2.7"
  region  = "us-east-1"
}
variable "image_id" {}

resource "aws_instance" "secOps" {
  ami = var.image_id
  instance_type = "t2.medium"

  tags = {
    Name = var.image_id
    Source_image = var.image_id
  }
}

# count = var.createInstanceLinux ? 1 : 0