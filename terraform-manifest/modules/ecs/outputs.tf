output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.boolean.name
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.boolean.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.boolean.arn
}
