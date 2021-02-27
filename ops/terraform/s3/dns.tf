resource "aws_route53_record" "quehosting_es" {
    zone_id = module.vars.hosted_zone_id
    name    = "quehosting.es"
    type    = "A"

    alias {
        name                    = aws_s3_bucket.quehosting_public_bucket.website_domain
        zone_id                 = aws_s3_bucket.quehosting_public_bucket.hosted_zone_id
        evaluate_target_health  = false
    }
}

resource "aws_route53_record" "www_quehosting_es" {
    zone_id = module.vars.hosted_zone_id
    name    = "www.quehosting.es"
    type    = "A"

    alias {
        name                    = aws_s3_bucket.www_quehosting_public_bucket.website_domain
        zone_id                 = aws_s3_bucket.www_quehosting_public_bucket.hosted_zone_id
        evaluate_target_health  = false
    }
}