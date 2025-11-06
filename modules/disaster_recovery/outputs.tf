output "dr_lambda_name" {
  description = "Nome da função Lambda do DR"
  value       = aws_lambda_function.dr_backup_lambda.function_name
}

output "dr_bucket_name" {
  description = "Bucket S3 usado pelo DR"
  value       = aws_s3_bucket.dr_bucket.bucket
}

output "dr_schedule_rule_name" {
  description = "Nome da regra de agendamento do EventBridge"
  value       = aws_cloudwatch_event_rule.daily_dr_schedule.name
}
