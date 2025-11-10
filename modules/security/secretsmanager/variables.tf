variable "secret_name" {
  description = "Nome do segredo no Secrets Manager."
  type        = string
  default     = "nextgenz-rds-secret"
}

variable "username" {
  description = "Usuário do banco de dados."
  type        = string
  default     = "admin"
}

variable "password" {
  description = "Senha do banco de dados."
  type        = string
  sensitive   = true
  default     = "Senai134"
}

variable "environment" {
  description = "Ambiente (ex: dev,prod)."
  type        = string
  default     = "prod"
}
