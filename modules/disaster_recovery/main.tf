#########################################
# Módulo: Disaster Recovery (RDS Only)
#########################################

resource "aws_lambda_function" "dr_backup_lambda" {
  filename         = var.lambda_zip_path
  function_name    = "nextgenz-dr-lambda"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  timeout          = 60

  environment {
    variables = {
      ENVIRONMENT     = var.environment
      RDS_INSTANCE_ID = var.rds_instance_id
      DR_COPY_REGION  = var.dr_copy_region
      AWS_REGION      = var.aws_region
      AWS_ACCOUNT_ID  = var.aws_account_id
    }
  }

  tags = {
    Project     = "NextGenZ"
    Environment = var.environment
  }
}

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

resource "aws_iam_role_policy" "lambda_policy" {
  name = "nextgenz-dr-lambda-policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds:CreateDBSnapshot",
          "rds:CopyDBSnapshot",
          "rds:DescribeDBSnapshots",
          "rds:DescribeDBInstances"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_cloudwatch_event_rule" "hourly_dr_schedule" {
  name                = "nextgenz-dr-hourly-schedule"
  schedule_expression = var.schedule_expression
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dr_backup_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.hourly_dr_schedule.arn
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.hourly_dr_schedule.name
  target_id = "invoke-nextgenz-dr-lambda"
  arn       = aws_lambda_function.dr_backup_lambda.arn
}
