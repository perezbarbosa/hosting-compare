resource "aws_cloudfront_distribution" "quehosting_cdn" {
  enabled = true

  origin {
    domain_name = aws_s3_bucket.quehosting_public_bucket.website_endpoint
    origin_id   = "quehosting.es"
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    target_origin_id       = "quehosting.es"
  }

  price_class         = "PriceClass_100"
  aliases             = ["quehosting.es"]
  default_root_object = "index.html"


  viewer_certificate {
    acm_certificate_arn      = module.vars.domain_ssl_arn
    minimum_protocol_version = "TLSv1.2_2019"
    ssl_support_method       = "sni-only"
  }

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }
}

resource "aws_cloudfront_distribution" "www_quehosting_cdn" {
  enabled = true

  origin {
    domain_name = aws_s3_bucket.www_quehosting_public_bucket.website_endpoint
    origin_id   = "www.quehosting.es"
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    target_origin_id       = "www.quehosting.es"
  }

  price_class = "PriceClass_100"
  aliases     = ["www.quehosting.es"]
  default_root_object = "index.html"

  viewer_certificate {
    acm_certificate_arn      = module.vars.domain_ssl_arn
    minimum_protocol_version = "TLSv1.2_2019"
  }

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }
}