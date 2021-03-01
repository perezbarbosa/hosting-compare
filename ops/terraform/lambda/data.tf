data "aws_subnet_ids" "public_subnets" {
  vpc_id = module.vars.vpc_id

  tags = {
    Tier = "Public"
  }
}
