#
# Main VPC
# With no internet connectivity, not even NatGWs 
#


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.77.0"

  name               = "quehosting"
  cidr               = "10.0.0.0/16"
  azs                = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  intra_subnets      = ["10.0.51.0/24", "10.0.52.0/24", "10.0.53.0/24"]
  enable_nat_gateway = false
  enable_vpn_gateway = false
}