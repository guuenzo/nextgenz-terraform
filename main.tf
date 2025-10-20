module "secretsmanager" {
  source       = "./modules/security/secretsmanager"

  secret_name  = "nextgenz-rds-secret"
  db_username  = "admin"
  db_password  = "Senha134"
}

