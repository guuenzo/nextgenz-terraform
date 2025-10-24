resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = "nextgenz-cloudtrail-logs"

  tags = {
    Name        = "nextgenz-cloudtrail-logs"
    Environment = "academic"
  }
}

resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket                  = aws_s3_bucket.cloudtrail_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudwatch_log_group" "cloudtrail_logs" {
  name              = "/aws/cloudtrail/logs"
  retention_in_days = 30

  tags = {
    Name        = "nextgenz-cloudtrail-logs"
    Environment = "academic"
  }
}

resource "aws_iam_role" "cloudtrail_role" {
  name = "nextgenz-cloudtrail-to-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "cloudtrail_policy" {
  name = "nextgenz-cloudtrail-policy"
  role = aws_iam_role.cloudtrail_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.cloudtrail_logs.arn}:*"
      }
    ]
  })
}

resource "aws_cloudtrail" "main" {
  name                          = "nextgenz-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_bucket.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  cloud_watch_logs_group_arn = aws_cloudwatch_log_group.cloudtrail_logs.arn
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_role.arn

  depends_on = [
    aws_cloudwatch_log_group.cloudtrail_logs,
    aws_iam_role.cloudtrail_role
  ]

  tags = {
    Name        = "nextgenz-cloudtrail"
    Environment = "academic"
  }
}
