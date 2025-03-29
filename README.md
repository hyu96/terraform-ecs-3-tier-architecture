# Terraform AWS Infrastructure

This Terraform project provisions a complete AWS infrastructure including:
- VPC with public and private subnets
- ECS (Elastic Container Service) cluster with Fargate tasks
- S3 bucket
- RDS (Relational Database Service) instance
- Secrets Manager for secure credential storage

## Prerequisites

- AWS account with appropriate permissions
- Terraform v1.0+ installed
- AWS CLI configured with credentials

## Usage

1. Clone this repository
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Review the execution plan:
   ```bash
   terraform plan
   ```
4. Apply the configuration:
   ```bash
   terraform apply
   ```

## Input Variables

| Variable | Description | Type | Default | Required |
|----------|-------------|------|---------|----------|
| aws_region | AWS region | string | - | yes |
| environment | Environment name (dev/prod) | string | - | yes |
| vpc_cidr | CIDR block for VPC | string | - | yes |
| az_count | Number of availability zones | number | - | yes |
| db_username | Database username | string | - | yes |
| db_password | Database password | string | - | yes (sensitive) |
| allowed_cidr_blocks | List of CIDR blocks allowed to access the database | list(string) | [] | no |

## Outputs

| Output | Description |
|--------|-------------|
| vpc_id | ID of the VPC |
| ecs_cluster_name | Name of the ECS cluster |
| s3_bucket_name | Name of the S3 bucket |
| rds_endpoint | Endpoint of the RDS instance |

## Modules

### VPC
Creates a VPC with public and private subnets across multiple availability zones.

### ECS
- Creates an ECS cluster
- Defines a Fargate task with nginx container
- Sets up required IAM roles and security groups
- Deploys an ECS service

### S3
Creates an S3 bucket with environment-specific naming.

### Secrets Manager
Stores database credentials securely.

### RDS
- Creates a PostgreSQL RDS instance
- Places it in private subnets
- Configures security group rules
- Uses credentials from Secrets Manager

## Example

```hcl
module "infrastructure" {
  source = "./terraform-manifest"

  aws_region          = "us-east-1"
  environment         = "dev"
  vpc_cidr            = "10.0.0.0/16"
  az_count            = 2
  db_username         = "admin"
  db_password         = "securepassword123"
  allowed_cidr_blocks = ["192.168.1.0/24"]
}
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.