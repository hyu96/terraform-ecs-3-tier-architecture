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

      health_check = {
        command      = ["CMD-SHELL", "curl -f http://localhost/ || exit 1"]
        interval     = 30        # seconds between checks
        timeout      = 5         # time to wait before failing the check
        retries      = 3         # how many times to retry before marking unhealthy
        start_period = 10        # wait time before starting checks (gives nginx time to start)
      }
      
      enable_cloudwatch_logging = true

      readonly_root_filesystem = false
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

  assign_public_ip = true
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