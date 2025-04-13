module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.environment}-vpc"
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  public_subnets  = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, i)]
  private_subnets = [for i in range(var.az_count) : cidrsubnet(var.vpc_cidr, 8, i + var.az_count)]

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Environment = var.environment
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "ecs" {
  source = "./modules/ecs"

  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnets
}

module "s3" {
  source = "./modules/s3"

  environment = var.environment
}

module "ssm_parameter" {
  source = "./modules/ssm_parameter"

  environment = var.environment
}

module "rds" {
  source = "./modules/rds"

  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnets
  db_username         = "${var.db_username}_${var.environment}"
  db_password         = module.ssm_parameter.db_password_value
  depends_on          = [module.ssm_parameter]
}