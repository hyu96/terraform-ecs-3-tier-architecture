resource "aws_ecr_repository" "boolean" {
  name                 = "boolean"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "boolean" {
  repository = aws_ecr_repository.boolean.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 30 images"
      action = {
        type = "expire"
      }
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 12
      }
    }]
  })
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
