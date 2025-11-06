variable "environment" {
  description = "Ambiente de execução (ex.: dev, prod)"
  type        = string
  default     = "prod"
}

variable "lambda_zip_path" {
  description = "Caminho do arquivo ZIP da Lambda"
  type        = string
}

variable "s3_bucket_name" {
  description = "Nome do bucket S3 usado pelo DR"
  type        = string
}

variable "ec2_instance_id" {
  description = "ID da instância EC2 a ser incluída no plano de backup (opcional)"
  type        = string
  default     = ""
}

variable "schedule_expression" {
  description = "Expressão CRON do EventBridge (ex.: cron(0 2 * * ? *))"
  type        = string
  default     = "cron(0 2 * * ? *)"
}

variable "dr_copy_dest_region" {
  description = "Região de destino para cópia dos backups (opcional)"
  type        = string
  default     = ""
}

