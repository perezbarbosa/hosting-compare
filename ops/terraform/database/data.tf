data "aws_subnet_ids" "example" {
  vpc_id = module.vars.vpc_id
}