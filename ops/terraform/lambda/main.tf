provider "aws" {
  region = module.vars.region
}

module "vars" {
  source = "../modules/vars"
}
