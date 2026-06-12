variable "vault_token" {
  description = "HashiCorp Vault root token"
  type        = string
  sensitive   = true
  default     = "root-token"
}

variable "db_password" {
  description = "PostgreSQL database password"
  type        = string
  sensitive   = true
  default     = "SecurePass123!"
}

variable "redis_password" {
  description = "Redis cache password"
  type        = string
  sensitive   = true
  default     = "RedisPass123!"
}

variable "namespace" {
  description = "Kubernetes namespace for application"
  type        = string
  default     = "portal-prod"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "securegarde"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}

variable "replicas" {
  description = "Number of replicas per service"
  type        = number
  default     = 1
}
