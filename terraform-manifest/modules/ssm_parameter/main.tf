data "aws_ssm_parameter" "db_password" {
  name = "/rds-db-password-${var.environment}"
}

output "db_password_value" {
  description = "Value of the database password parameter"
  value       = data.aws_ssm_parameter.db_password.value
  sensitive   = true
}
