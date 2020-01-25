# Create a new instance of the latest Ubuntu 14.04 on an
# t2.micro node with an AWS Tag naming it "HelloWorld"

provider "aws" {
  version = "~> 2.7"
  region  = "us-east-1"
}

variable "image_id" {
  type        = string
  description = "The id of the machine image (AMI) to use for the server."
}

resource "aws_instance" "web" {
  ami           = "${var.image_id}"
  instance_type = "t2.micro"

  tags = {
    Name = "HelloWorld"
  }
}