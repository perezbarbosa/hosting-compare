data "aws_subnet_ids" "private_subnets" {
  vpc_id = module.vars.vpc_id

  tags = {
    Tier = "Private"
  }
}
