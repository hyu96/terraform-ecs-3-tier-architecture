# Terraform Implementation Plan

## Directory Structure
```
terraform-manifest/
├── main.tf
├── variables.tf
├── outputs.tf
├── environments/
│   ├── dev.tfvars
│   └── prod.tfvars
└── modules/
    ├── vpc/
    ├── ecs/
    ├── s3/
    └── rds/
```

## Implementation Approach

### 1. Root Module
- `main.tf`: Main configuration calling all modules
- `variables.tf`: Common variables across environments
- `outputs.tf`: Output values for other stacks
- `environments/`: Folder containing environment-specific variables files

### 2. Modules

#### VPC Module
- Public subnets in 2 AZs
- No private subnets
- Internet Gateway

#### ECS Module
- Fargate cluster
- Small task size
- Public IP assignment

#### S3 Module
- Basic bucket configuration
- Environment-suffixed bucket name

#### RDS Module
- Small Postgres instance
- Public accessibility (since no private network)
- Environment-suffixed instance name

### 3. Environment Separation
- Use `terraform apply -var-file=environments/dev.tfvars` for dev
- Use `terraform apply -var-file=environments/prod.tfvars` for prod
- Common configuration in `variables.tf`
- Environment-specific values in respective `.tfvars` files

### 4. Naming Convention
- All resources will follow pattern: `{service}-{resource}-{environment}`
- Example: `app-ecs-cluster-dev`, `app-rds-instance-prod`

## Next Steps
1. Review this updated plan
2. Approve to proceed with implementation
3. Switch to code mode for implementation