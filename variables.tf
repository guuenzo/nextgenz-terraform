variable "aws_region" {
  default = "us-east-1"
}

variable "aws_profile" {
  default = "default"
}

variable "db_password" {
  sensitive = true
}

variable "username" {
  sensitive = true
}