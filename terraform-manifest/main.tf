terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "boolean-terraform-state"
    key            = "terraform/state/terraform.tfstate"
    region         = "ap-southeast-1"
  }
}

provider "aws" {
  region = var.aws_region
}

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

module "secrets_manager" {
  source = "./modules/secrets_manager"
  
  environment = var.environment
  db_password = var.db_password
}

module "rds" {
  source = "./modules/rds"
  
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  db_username       = var.db_username
  db_password_secret_arn = module.secrets_manager.db_password_secret_arn
  allowed_cidr_blocks = var.allowed_cidr_blocks
  ecs_security_group_id = module.ecs.service_security_group_id
  depends_on = [ module.secrets_manager ]
}