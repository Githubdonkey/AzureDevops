resource "aws_instance" "linuxU1804" {
  count = var.createInstanceLinux ? 1 : 0
  ami           = "ami-07d0cf3af28718ef8"
  instance_type = "t2.micro"

  tags = {
    Name = "Ubuntu_18.04"
  }
}
resource "aws_instance" "win2016" {
  count = var.createInstanceWin ? 1 : 0
  ami           = "ami-07d0cf3af28718ef8"
  instance_type = "t2.micro"

  tags = {
    Name = "Windows 2016"
  }
}