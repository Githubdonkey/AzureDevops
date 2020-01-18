provider "aws" {
   region  = "us-east-1"
}

module "s3_bucket" {
  source                        = "git::https://github.com/Githubdonkey/teffaformPacker//modules/s3"
  createS3_public               = "${var.createS3_public}"
  createS3_private              = "${var.createS3_private}"
}

module "aws_instance" {
  source                        = "git::https://github.com/Githubdonkey/teffaformPacker//modules/ec2"
  createInstanceLinux           = "${var.createInstanceLinux}"
  createInstanceWin             = "${var.createInstanceWin}"
}
