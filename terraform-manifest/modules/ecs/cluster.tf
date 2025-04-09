module "ecs_cluster" {
  source = "terraform-aws-modules/ecs/aws//modules/cluster"

  cluster_name = "tf-learning-cluster-${var.environment}"

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  tags = {
    Environment = "Development"
    Project     = "EcsEc2"
  }
}
resource "aws_ecs_cluster" "boolean" {
  name = "boolean-ecs-cluster-${var.environment}"

  tags = {
    Name = "ecs-cluster-${var.environment}"
  }
}

module "order-service" {
    source = "./order-service"

    depends_on = [ aws_ecs_cluster.boolean ]
    service_name = "order-service"
    environment = var.environment
    desired_count = 1
    cpu = 256
    memory = 512
    vpc_id = var.vpc_id
    public_subnet_ids = var.public_subnet_ids
    cluster_id = aws_ecs_cluster.boolean.id
}
