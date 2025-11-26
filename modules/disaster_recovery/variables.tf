variable "environment" {
  description = "Ambiente de execução"
  type        = string
  default     = "prod"
}

variable "lambda_zip_path" {
  description = "Caminho do arquivo ZIP da Lambda"
  type        = string
}

variable "rds_instance_id" {
  description = "ID da instância RDS"
  type        = string
}

variable "schedule_expression" {
  description = "Expressão CRON do EventBridge"
  type        = string
  default     = "cron(0 * * * ? *)"
}

variable "dr_copy_region" {
  description = "Região para onde o snapshot será copiado"
  type        = string
}

variable "aws_region" {
  description = "Região atual da AWS"
  type        = string
}

variable "aws_account_id" {
  description = "Account ID da AWS"
  type        = string
}

