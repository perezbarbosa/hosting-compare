data "aws_subnet_ids" "private_subnets" {
  vpc_id = module.vars.vpc_id

  tags = {
    Tier = "Private"
  }
}

data "aws_security_group" "search_lambda_sg" {
  filter {
    name = "group-name"
    values = ["search-lambda-sg"]
  }
}
