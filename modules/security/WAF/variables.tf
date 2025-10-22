# Define o nome que o seu WAF terá no console da AWS.
variable "waf_name" {}

# Define o nome da métrica do CloudWatch (baseado no nome do WAF).
variable "waf_metric_name" {}
  

# Define o escopo: REGIONAL (para ALB/API Gateway) ou CLOUDFRONT (para CDN).
variable "waf_scope" {}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile name"
  type        = string
  default     = "default"
}
