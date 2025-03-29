data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = var.db_password_secret_arn
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids
  
  tags = {
    Name = "${var.environment}-rds-subnet-group"
  }
}

data "aws_rds_engine_version" "postgres" {
  engine  = "postgres"
  version = "15"
  default_only = true
}

resource "aws_db_instance" "main" {
  identifier             = "boolean-rds-instance-${var.environment}"
  allocated_storage      = var.allocated_storage
  storage_type           = var.storage_type

  engine                 = "postgres"
  engine_version         = data.aws_rds_engine_version.postgres.version
  instance_class         = var.instance_class
  db_name                = replace("boolean_${var.environment}", "/[^a-zA-Z0-9]/", "")
  username               = var.db_username
  password               = jsondecode(data.aws_secretsmanager_secret_version.db_password.secret_string)
  parameter_group_name   = "default.${data.aws_rds_engine_version.postgres.parameter_group_family}"
  publicly_accessible    = false
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  
  tags = {
    Name = "${var.environment}-rds-instance"
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.environment}-rds-sg"
  description = "Allow inbound PostgreSQL access"
  vpc_id      = var.vpc_id
  
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [var.ecs_security_group_id]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.environment}-rds-sg"
  }
}