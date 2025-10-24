output "cloudtrail_name" {
  description = "Nome do CloudTrail criado"
  value       = aws_cloudtrail.main.name
}

output "cloudtrail_s3_bucket" {
  description = "Bucket S3 que armazena os logs do CloudTrail"
  value       = aws_s3_bucket.cloudtrail_bucket.bucket
}

output "cloudtrail_cloudwatch_log_group" {
  description = "Log Group do CloudWatch integrado ao CloudTrail"
  value       = aws_cloudwatch_log_group.cloudtrail_logs.name
}
