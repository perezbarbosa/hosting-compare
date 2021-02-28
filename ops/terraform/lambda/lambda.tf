resource "aws_lambda_function" "search_lambda" {
  filename      = "search.zip"
  function_name = "search"
  role          = aws_iam_role.lambda_exec_iam.arn
  handler       = "search.handler"

  source_code_hash = filebase64sha256("search.zip")

  runtime = "python3.7"

  environment {
    variables = {
      MYSQL_HOST = "",
      MYSQL_DB = "",
      MYSQL_USER = "",
      MYSQL_PASS= ""
    }
  }
}
