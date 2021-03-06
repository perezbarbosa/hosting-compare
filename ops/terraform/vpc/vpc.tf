data "aws_vpc" "default_vpc" {
  id = module.vars.vpc_id
}

resource "aws_route_table" "default_private_rt" {
  vpc_id = data.aws_vpc.default_vpc.id

  tags = {
    Name = "default-private"
  }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id            = data.aws_vpc.default_vpc.id
  cidr_block        = "172.31.64.0/20"
  availability_zone = "${module.vars.region}a"

  tags = {
    Name = "default-private-${module.vars.region}a",
    Tier = "Private"
  }

}

resource "aws_subnet" "private_subnet_b" {
  vpc_id            = data.aws_vpc.default_vpc.id
  cidr_block        = "172.31.80.0/20"
  availability_zone = "${module.vars.region}b"

  tags = {
    Name = "default-private-${module.vars.region}b",
    Tier = "Private"
  }

}

resource "aws_route_table_association" "default_private_a_rt_association" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.default_private_rt.id
}

resource "aws_route_table_association" "default_private_b_rt_association" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.default_private_rt.id
}
