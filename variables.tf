variable "aws_region" {
  description = "Região onde os recursos primários são criados"
  type        = string
}

variable "aws_account_id" {
  description = "ID da conta AWS usada pelo módulo DR"
  type        = string
}

variable "dr_copy_region" {
  description = "Região de cópia do snapshot RDS"
  type        = string
}
