variable "region" {
  default = "eu-west-2"
}

output "region" {
  value = var.region
}

variable "vpc_id" {
  default = "vpc-2260454a"
}

output "vpc_id" {
  value = var.vpc_id
}

variable "vpc_cidr" {
  default = "172.31.0.0/16"
}

output "vpc_cidr" {
  value = var.vpc_cidr
}

variable "hosted_zone_id" {
  default = "Z0570132CNF09ZKCH1YT"
}

output "hosted_zone_id" {
  value = var.hosted_zone_id
}

variable "domain_ssl_arn" {
  description = "The Quehosting.es domain SSL certificate, managed by ACM"
  default     = "arn:aws:acm:us-east-1:865985078345:certificate/f30585ba-4e8b-4043-b2f8-9edb43ca1035"
}

output "domain_ssl_arn" {
  value = var.domain_ssl_arn
}
