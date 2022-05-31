resource "aws_s3_bucket" "fxlinkpayloadbucket" {
  bucket = "fxlinkpayload"
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "fxlinkdefault01" {
  bucket = aws_s3_bucket.fxlinkpayloadbucket.id

  block_public_acls   = true
  block_public_policy = true
}



