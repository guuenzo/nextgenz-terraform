###########################################
# Modulo Secrets Manager
###########################################
module "secretsmanager" {
  source        = "./modules/security/secretsmanager"
  secret_name   = var.secret_name
  username      = var.username
  password      = var.password
  environment   = var.environment

  aws_account_id = var.aws_account_id

}


###########################################
# Módulo RDS
###########################################
module "rds" {
  source      = "./modules/database"
  environment = "prod"
  db_name     = "nextgenzdb"
  secret_name = "nextgenz-rds-secret"

  backup_retention_period = 7
  instance_class          = "db.t3.micro"
  allocated_storage       = 20

  project = "nextgenz"
  owner   = "Consultoria NextGenZ"

  depends_on = [module.secretsmanager]
}

output "rds_endpoint" {
  value       = module.rds.rds_endpoint
  description = "Endpoint do banco de dados RDS"
}

###########################################
# Módulo Disaster Recovery (RDS Only)
###########################################
module "disaster_recovery" {
  source      = "./modules/disaster_recovery"
  environment = "prod"

  lambda_zip_path = "${path.module}/modules/disaster_recovery/lambda_function.zip"

  # Obtém automaticamente o ID do RDS criado acima
  rds_instance_id = module.rds.rds_instance_id



  schedule_expression = "cron(0 * * * ? *)" # RPO de 1 hora
  dr_copy_region      = "us-east-1"         # região de DR


  aws_region     = var.aws_region
  aws_account_id = var.aws_account_id

  depends_on = [
    module.rds,
    module.secretsmanager
  ]
}

###########################################
# Outputs do módulo Disaster Recovery
###########################################
output "dr_lambda_name" {
  description = "Lambda que executa a rotina de DR"
  value       = module.disaster_recovery.dr_lambda_name
}

output "dr_schedule_rule_name" {
  description = "Regra do EventBridge responsável por agendar o DR"
  value       = module.disaster_recovery.dr_schedule_rule_name
}

