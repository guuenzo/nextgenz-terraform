module "secretsmanager" {
  source      = "./modules/security/secretsmanager"
  secret_name = "nextgenz-rds-secret"
  username    = "admin"
  password    = "Senai134"
  environment = "prod"
}


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


##############################
# Módulo: Disaster Recovery (DR)
##############################

module "disaster_recovery" {
  source            = "./modules/disaster_recovery"
  environment       = "prod"
  lambda_zip_path   = "${path.module}/modules/disaster_recovery/lambda_function.zip"
  s3_bucket_name    = "nextgenz-dr-backup-bucket"
  ec2_instance_id   = "" # pode deixar vazio se ainda não houver EC2
  schedule_expression = "cron(0 2 * * ? *)"
  dr_copy_dest_region = "us-east-1"

  depends_on = [
    module.rds,
    module.secretsmanager
  ]
}


##############################
# Saída do módulo Disaster Recovery (root)
##############################

output "dr_lambda_name" {
  description = "Nome da função Lambda do módulo DR"
  value       = module.disaster_recovery.dr_lambda_name
}

output "dr_bucket_name" {
  description = "Nome do bucket S3 usado pelo módulo DR"
  value       = module.disaster_recovery.dr_bucket_name
}

output "dr_schedule_rule_name" {
  description = "Nome da regra de agendamento (EventBridge) do módulo DR"
  value       = module.disaster_recovery.dr_schedule_rule_name
}

