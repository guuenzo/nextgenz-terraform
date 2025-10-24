#CHAMADA DOS MODULES

module "vpc" {
  source         = "./modules/networking/vpc"
  vpc_cidr       = "10.0.0.0/16"
  vpc_name       = "my-vpc"
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
  azs            = ["us-east-1a", "us-east-1b"]
}