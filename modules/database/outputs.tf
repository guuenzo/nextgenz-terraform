# Endpoint do RDS
output "rds_endpoint" {
  description = "Endpoint do banco de dados RDS."
  value       = aws_db_instance.rds_instance.endpoint
}

# ARN do segredo (lido via data source)
output "secret_arn" {
  description = "ARN do segredo usado pelo RDS."
  value       = data.aws_secretsmanager_secret.rds_secret.arn
}

# Nome do segredo (lido via data source)
output "secret_name" {
  description = "Nome do segredo usado pelo RDS."
  value       = data.aws_secretsmanager_secret.rds_secret.name
}
