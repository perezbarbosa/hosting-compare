resource "aws_lambda_function" "search_lambda_function" {
  filename      = "~/search.zip"
  function_name = "search"
  role          = aws_iam_role.lambda_exec_iam.arn
  handler       = "search.handler"

  source_code_hash = filebase64sha256("~/search.zip")

  runtime = "python3.7"

  environment {
    variables = {
      MYSQL_HOST = var.db_host,
      MYSQL_DB   = var.db_name,
      MYSQL_USER = var.db_user,
      MYSQL_PASS = var.db_pass
    }
  }

  vpc_config {
    security_group_ids = [aws_security_group.search_lambda_sg.id]
    subnet_ids         = data.aws_subnet_ids.public_subnets.ids
  }
}

resource "aws_security_group" "search_lambda_sg" {
  name        = "search-lambda-sg"
  description = "Search lambda function sg with no rules. Just used by RDS to allow its access."
  vpc_id      = module.vars.vpc_id
}
