resource "aws_iam_role" "lambda_exec_iam" {
  name = "iam_for_lambda_to_exec"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Manage Network Interfaces to connect to the VPC
# https://docs.aws.amazon.com/lambda/latest/dg/configuration-vpc.html#vpc-permissions
resource "aws_iam_role_policy_attachment" "name" {
  role       = aws_iam_role.lambda_exec_iam
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  
}
