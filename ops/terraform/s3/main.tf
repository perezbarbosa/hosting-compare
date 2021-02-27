# https://rogerwelin.github.io/aws/serverless/terraform/lambda/2019/03/18/build-a-serverless-website-from-scratch-with-lambda-and-terraform.html

provider "aws" {
  region = "eu-west-2"
}

module "vars" {
  source = "../modules/vars"
}