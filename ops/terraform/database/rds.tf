resource "aws_db_instance" "quehosting_db" {
  allocated_storage       = 20
  engine                  = "mariadb"
  engine_version          = "10.5.8"
  instance_class          = "db.t2.micro"
  id                      = "quehosting-dev" # RDS id
  name                    = "quehostingdev"  # Defaul database name
  username                = "queadmin"
  password                = "fakepassword"
  parameter_group_name    = "default.mariadb10.5"
  skip_final_snapshot     = true
  backup_retention_period = 0
  maintenance_window      = "Mon:04:00-Mon:04:30"
  vpc_security_group_ids  = [aws_security_group.quehosting_db_sg.id]
}

resource "aws_db_subnet_group" "default_vpc_01a101f1d11874973" {
  name       = "default-vpc-01a101f1d11874973"
  subnet_ids = data.aws_subnet_ids.example.ids
}

resource "aws_security_group" "quehosting_db_sg" {
  name        = "quehosting_rds_sg"
  description = "Allow MySQL traffic"
  vpc_id      = module.vars.vpc_id

  ingress {
    description = "MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [module.vars.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}