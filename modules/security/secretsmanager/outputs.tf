output "secret_arn" {
  description = "ARN do segredo criado."
  value       = aws_secretsmanager_secret.rds_secret.arn
}

output "secret_name" {
  description = "Nome do segredo criado."
  value       = aws_secretsmanager_secret.rds_secret.name
}
