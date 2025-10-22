resource "aws_secretsmanager_secret" "rds_secret" {
  name        = var.secret_name
  description = "Credenciais do banco de dados RDS"
  recovery_window_in_days = 30  # tempo de retenção em caso de exclusão

  tags = {
    Name        = var.secret_name
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "rds_secret_value" {
  secret_id = aws_secretsmanager_secret.rds_secret.id

  secret_string = jsonencode({
    username = var.username
    password = var.password
  })
}
