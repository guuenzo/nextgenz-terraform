variable "instance_identifier" {}

variable "environment" {}

variable "db_name" {}

variable "engine_version" {}

variable "instance_class" {}

variable "allocated_storage" {}

variable "backup_retention_period" {}

variable "subnet_ids" {
  type = list(string)
}

variable "db_sg_id" {}

variable "db_username" {}

variable "db_password" {}