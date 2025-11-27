variable "aws_region" {
  description = "Região onde os recursos primários são criados"
  type        = string
}

variable "aws_account_id" {
  description = "ID da conta AWS"
  type        = string
}

variable "dr_copy_region" {
  description = "Região de cópia do snapshot RDS"
  type        = string
}

variable "username" {
  description = "Username para o banco de dados"
  type        = string
}

variable "password" {
  description = "Password para o banco de dados"
  type        = string
  sensitive   = true
}

variable "secret_name" {
  description = "Nome do secret no AWS Secrets Manager"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, prod, etc.)"
  type        = string
}

