locals {
  region  = "us-east-1"
  region_cloudfront  = "us-east-1"

  vpc_cidr = "10.0.0.0/20"
  public_subnet_1_cidr = "10.0.0.0/23"
  public_subnet_2_cidr = "10.0.2.0/23"
  private_subnet_1_cidr = "10.0.4.0/23"
  private_subnet_2_cidr = "10.0.6.0/23"

  az1 = "us-east-1a"
  az2 = "us-east-1b"
}
