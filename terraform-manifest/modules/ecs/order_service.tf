module "order_service" {
  source = "terraform-aws-modules/ecs/aws//modules/service"
  version = "5.12.0"
  
  depends_on  = [module.ecs_cluster, aws_service_discovery_private_dns_namespace.ecs_service_discovery]
  name        = "order-service"
  cluster_arn = module.ecs_cluster.arn

  cpu    = 256
  memory = 512

  # Container definition(s)
  container_definitions = {
    order-service = {
      cpu       = 256
      memory    = 512
      essential = true
      image     = "nginx:latest"
      port_mappings = [
        {
          name          = "order-service"
          containerPort = 80
          protocol      = "tcp"
        }
      ]

      enable_cloudwatch_logging = false
    }
  }

  service_connect_configuration = {
    namespace = aws_service_discovery_private_dns_namespace.ecs_service_discovery.arn
    service = {
      client_alias = {
        port     = 80
        dns_name = "order-service"
      }
      port_name      = "order-service"
      discovery_name = "order-service"
    }
  }

  subnet_ids = var.public_subnet_ids
  security_group_rules = {
    alb_ingress_3000 = {
      type        = "ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Service port"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}