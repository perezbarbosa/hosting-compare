resource "aws_route53_record" "quehosting_es" {
    zone_id = module.vars.hosted_zone_id
    name    = "quehosting.es"
    type    = "A"

    alias {
        name                    = aws_cloudfront_distribution.quehosting_cdn.domain_name
        zone_id                 = aws_cloudfront_distribution.quehosting_cdn.hosted_zone_id
        evaluate_target_health  = false
    }
}

resource "aws_route53_record" "www_quehosting_es" {
    zone_id = module.vars.hosted_zone_id
    name    = "www.quehosting.es"
    type    = "A"

    alias {
        name                    = aws_cloudfront_distribution.www_quehosting_cdn.domain_name
        zone_id                 = aws_cloudfront_distribution.www_quehosting_cdn.hosted_zone_id
        evaluate_target_health  = false
    }
}