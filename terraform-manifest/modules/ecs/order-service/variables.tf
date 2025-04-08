variable "environment" {
  description = "Environment name (dev/prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "service_name" {
  description = "Service name"
  type = string
}

variable "cpu" {
  description = "CPU"
  type = number
}

variable "memory" {
  description = "Memory"
  type = number
}

variable "desired_count" {
  description = "Desired count"
  type = number
}

variable "cluster_id" {
  description = "Cluster ID"
  type = string
}