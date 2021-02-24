# https://rogerwelin.github.io/aws/serverless/terraform/lambda/2019/03/18/build-a-serverless-website-from-scratch-with-lambda-and-terraform.html

provider "aws" {
  region = module.vars.region
}

module "vars" {
  source = "../modules/vars"
}