# Create a new instance of the latest Ubuntu 14.04 on an
# t2.micro node with an AWS Tag naming it "HelloWorld"

provider "aws" {
  version = "~> 2.7"
  region  = "us-east-1"
}
variable "image_id" {}

resource "aws_instance" "secOps" {
  ami = var.image_id
  instance_type = "t2.large"

  tags = {
    Name = var.image_id
    Source_image = var.image_id
  }
}

# count = var.createInstanceLinux ? 1 : 0