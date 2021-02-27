variable "region" {
  default = "eu-west-2"
}

output "region" {
  value = var.region
}

variable "vpc_id" {
  default = "vpc-01a101f1d11874973"
}

output "vpc_id" {
  value = var.vpc_id
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
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