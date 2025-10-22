module "secretsmanager" {
  source = "./modules/security/secretsmanager"
  secret_name = "nextgenz-rds-secret"
  username    = "admin"
  password    = "Senai134"
  environment = "prod"
}


module "rds" {
  source = "./modules/database"

  environment = "prod"
  db_name     = "nextgenzdb"
  secret_name = "nextgenz-rds-secret"  # 🔄 nome correto

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
