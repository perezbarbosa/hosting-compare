resource "aws_s3_bucket" "quehosting_public_bucket" {
  bucket = "quehosting"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "404.html"
  }
}