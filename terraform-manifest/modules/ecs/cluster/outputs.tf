output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.boolean.name
}

output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.api-gateway.name
}

output "task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = aws_ecs_task_definition.api-gateway-task.arn
}

output "service_security_group_id" {
  description = "ID of the ECS service security group"
  value       = aws_security_group.ecs_service.id
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.boolean.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.boolean.arn
}
