resource "aws_service_discovery_private_dns_namespace" "ecs_service_discovery" {
  name        = "tf-learning"
  description = "ECS service discovery"
  vpc         = var.vpc_id
}
