terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = "~> 1.11.3"
  
  backend "s3" {
    bucket = "boolean-terraform-state"
    key    = "terraform/state/terraform.tfstate"
    region = "ap-southeast-1"
  }
}
