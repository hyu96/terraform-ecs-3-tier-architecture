module "order_service" {
  source = "terraform-aws-modules/ecs/aws//modules/service"

  depends_on = [ module.ecs_cluster ]
  name        = "order-service"
  cluster_arn = module.ecs_cluster.arn

  cpu    = 256
  memory = 512

  # Container definition(s)
  container_definitions = {
    order-service = {
      cpu       = 512
      memory    = 1024
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
    namespace = "example"
    service = {
      client_alias = {
        port     = 80
        dns_name = "ecs-sample"
      }
      port_name      = "ecs-sample"
      discovery_name = "ecs-sample"
    }
  }

  subnet_ids = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]
  security_group_rules = {
    alb_ingress_3000 = {
      type                     = "ingress"
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = "sg-12345678"
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
    Environment = "dev"
    Terraform   = "true"
  }
}