terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = local.region
}

provider "aws" {
  alias = "cloudfront"
  region = local.region_cloudfront
}
