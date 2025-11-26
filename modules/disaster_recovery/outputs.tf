output "dr_lambda_name" {
  description = "Nome da função Lambda responsável pelos snapshots do RDS"
  value       = aws_lambda_function.dr_backup_lambda.function_name
}

output "dr_lambda_arn" {
  description = "ARN da função Lambda de DR"
  value       = aws_lambda_function.dr_backup_lambda.arn
}

output "dr_schedule_rule_name" {
  description = "Nome da regra do EventBridge que agenda o DR (snapshot horário)"
  value       = aws_cloudwatch_event_rule.hourly_dr_schedule.name
}
