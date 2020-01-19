resource "aws_s3_bucket" "gitdonkeymainpublic" {
  count = var.createS3_public ? 1 : 0
  bucket = "gitdonkeymainpublic"
  acl    = "private"

  tags = {
    Name        = "My bucket public"
    Environment = "Dev"
  }
}
resource "aws_s3_bucket" "gitdonkeymainprivate" {
  count = var.createS3_private ? 1 : 0
  bucket = "gitdonkeymainprivate"
  acl    = "private"

  tags = {
    Name        = "My bucket private"
    Environment = "Dev"
  }
}