provider "aws" {
  version = "~> 2.7"
  region  = "us-east-1"
}

variable "ImageId" {}
variable "ImageName" {}
variable "dataSyncAgent" {
  type = string
  default = "test"
}

variable "ud" {
  type = string
  default = "userdata.sh.tpl"
}

variable "subnet_prv1" {
  description = "Public"
  default = "subnet-053b04da41ec7b5e8"
}

variable "sg_ec2" {
  description = "Public"
  default = "sg-029cf33ed20b2e6e8"
}

data "aws_vpc" "selected" {
  id = "vpc-04b916508498cf21e"
}

data "aws_security_group" "selected" {
  id = "sg-029cf33ed20b2e6e8"
}

#resource "aws_security_group" "subnet" {
#  vpc_id = "${data.aws_subnet.selected.vpc_id}"
#
#  ingress {
#    cidr_blocks = ["${data.aws_subnet.selected.cidr_block}"]
#    from_port   = 80
#    to_port     = 80
#    protocol    = "tcp"
#  }
#}


resource "aws_instance" "dataSyncAgent" {
  #count = var.ImageName == "DataSync_latest" ? 1 : 0
  ami = var.ImageId
  instance_type = var.ImageName == "DataSync_latest" ? "t2.micro" : "t2.2xlarge"
  user_data = templatefile(var.ud, {
    livetime = 10
    imagename = var.ImageId
  })
  key_name = "9-25"
  associate_public_ip_address = true
  subnet_id = var.subnet_prv1
  vpc_security_group_ids = [
      var.sg_ec2,
  ]
  tags = {
    Name = var.ImageName
    Source_image = var.ImageId
  }
}

output "dataSyncAgent" {
  value = var.dataSyncAgent
}

output "ImageId" {
  value = var.ImageId
}

output "ImageName" {
  value = var.ImageName
}







#resource "aws_instance" "secOps" {
#  ami = var.dataSyncAgent != "" ? var.dataSyncAgent : var.ImageId
#  # count = var.dataSyncAgent ? 1 : 0
#  # ami = var.ImageId
#  instance_type = "t2.2xlarge"

#  tags = {
#    Name = var.ImageName
#    Source_image = var.ImageId
#  }
#}

# count = var.createInstanceLinux ? 1 : 0