# Create a new instance of the latest Ubuntu 14.04 on an
# t2.micro node with an AWS Tag naming it "HelloWorld"

variable "image_id" {}

module "ubuntu" {
  source = "./modules/aws/ec2"
  image_id = var.image_id
}