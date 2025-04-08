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
