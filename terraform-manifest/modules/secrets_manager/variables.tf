variable "environment" {
  description = "Environment name (dev/prod)"
  type        = string
}

variable "db_password" {
  description = "Database password to store in Secrets Manager"
  type        = string
  sensitive   = true
}