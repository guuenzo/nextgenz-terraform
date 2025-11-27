resource "aws_secretsmanager_secret" "rds_secret" {
  name                    = var.secret_name
  description             = "Credenciais do banco de dados RDS"
  recovery_window_in_days = 30

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

resource "aws_secretsmanager_secret_policy" "rds_secret_policy" {
  secret_arn = aws_secretsmanager_secret.rds_secret.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowDescribeSecretForRoot"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::" + var.aws_account_id + ":root"
        }
        Action = [
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue",
          "secretsmanager:ListSecrets"
        ]
        Resource = aws_secretsmanager_secret.rds_secret.arn
      }
    ]
  })
}

