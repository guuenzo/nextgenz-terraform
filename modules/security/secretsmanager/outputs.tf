output "secret_arn" {
  value = aws_secretsmanager_secret.rds_secret.arn
}

output "secret_name" {
  value = aws_secretsmanager_secret.rds_secret.name
}