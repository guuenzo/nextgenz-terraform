##############################
# Módulo: Disaster Recovery (DR)
##############################

# Função Lambda de backup
resource "aws_lambda_function" "dr_backup_lambda" {
  filename         = var.lambda_zip_path
  function_name    = "nextgenz-dr-lambda"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  timeout          = 60

  environment {
    variables = {
      ENVIRONMENT      = var.environment
      S3_BUCKET_NAME   = var.s3_bucket_name
      EC2_INSTANCE_ID  = var.ec2_instance_id
      DR_COPY_REGION   = var.dr_copy_dest_region
    }
  }

  tags = {
    Project     = "NextGenZ"
    Environment = var.environment
  }
}

# Função IAM Role para a Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "nextgenz-dr-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Permissões da Lambda
resource "aws_iam_role_policy_attachment" "lambda_basic_exec" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Bucket S3 para metadados/logs do DR
resource "aws_s3_bucket" "dr_bucket" {
  bucket = var.s3_bucket_name
  tags = {
    Project     = "NextGenZ"
    Environment = var.environment
  }
}

# Cofre de backup
resource "aws_backup_vault" "main" {
  count = var.ec2_instance_id != "" ? 1 : 0
  name  = "nextgenz-backup-vault"
  tags = {
    Project     = "NextGenZ"
    Environment = var.environment
  }
}

# Plano de backup EC2 (só cria se houver instância definida)
resource "aws_backup_plan" "ec2_backup_plan" {
  count = var.ec2_instance_id != "" ? 1 : 0
  name  = "nextgenz-ec2-backup-plan"

  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.main[0].name
    schedule          = "cron(0 2 * * ? *)" # executa às 02:00 UTC
  }

  tags = {
    Project     = "NextGenZ"
    Environment = var.environment
  }
}

# Regra de agendamento do EventBridge (executa Lambda diariamente)
resource "aws_cloudwatch_event_rule" "daily_dr_schedule" {
  name                = "nextgenz-dr-daily-schedule"
  schedule_expression = var.schedule_expression
}

# Permissão para o EventBridge invocar a Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dr_backup_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_dr_schedule.arn
}

# Target da regra (chama a Lambda)
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_dr_schedule.name
  target_id = "invoke-nextgenz-dr-lambda"
  arn       = aws_lambda_function.dr_backup_lambda.arn
}

# (Opcional) replicação da AMI em outra região
# resource "aws_backup_region_settings" "cross_region" {
#   resource_type_opt_in_preference = {
#     EC2 = true
#   }
# }



