variable "environment" {
  description = "Ambiente (ex: dev, prod)."
  type        = string
  default     = "prod"
}

variable "db_name" {
  description = "Nome do banco."
  type        = string
  default     = "nextgenzdb"
}

variable "secret_name" {
  description = "Nome do segredo no Secrets Manager."
  type        = string
  default     = "nextgenz-rds-secret" # 🔄 atualizado
}

variable "engine_version" {
  description = "Versão do MariaDB."
  type        = string
  default     = "10.11.4"
}

variable "instance_class" {
  description = "Classe da instância RDS."
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Tamanho do armazenamento (GB)."
  type        = number
  default     = 20
}

variable "backup_retention_period" {
  description = "Dias de retenção dos backups automáticos."
  type        = number
  default     = 7
}

variable "project" {
  description = "Nome do projeto."
  type        = string
  default     = "nextgenz"
}

variable "owner" {
  description = "Responsável ou área proprietária."
  type        = string
  default     = "Consultoria NextGenZ"
}
