resource "aws_s3_bucket" "quehosting_public_bucket" {
  bucket = "quehosting.es"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "404.html"
  }
}

# https://docs.aws.amazon.com/AmazonS3/latest/userguide/how-to-page-redirect.html#redirect-endpoint-host
# https://simpleit.rocks/web/hostings/redirect-http-to-https-and-www-to-non-www-with-aws-s3-bucket-cloudfront-route-53-and-a-custom-domain/
# https://medium.com/faun/how-to-host-your-static-website-with-s3-cloudfront-and-set-up-an-ssl-certificate-9ee48cd701f9
resource "aws_s3_bucket" "www_quehosting_public_bucket" {
  bucket = "www.quehosting.es"
  acl    = "public-read"

  website {
    redirect_all_requests_to = "https://quehosting.es"
  }
}

resource "aws_s3_bucket_policy" "quehosting_public_bucket_policy" {
  bucket = aws_s3_bucket.quehosting_public_bucket.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression's result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "PublicReadGetObject",
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : [
          "s3:GetObject"
        ],
        "Resource" : [
          "arn:aws:s3:::quehosting.es/*"
        ]
      }
    ]
  })
}