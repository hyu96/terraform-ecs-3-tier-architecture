variable "environment" {
  description = "Environment name (dev/prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Name of the SSM Parameter containing the database password"
  type        = string
}

variable "allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = number
  default     = 20
}

variable "storage_type" {
  description = "The storage type (e.g., gp2, io1)"
  type        = string
  default     = "gp2"
}

variable "instance_class" {
  description = "The instance class of the RDS instance"
  type        = string
  default     = "db.t3.micro"
}
