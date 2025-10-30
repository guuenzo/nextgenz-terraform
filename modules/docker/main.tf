resource "aws_ecr_repository" "main" {
  name = var.repo_name
  image_tag_mutability = "MUTABLE"
  encryption_configuration {
    encryption_type = "AES-256"
  }

  tags = {
    Name = var.repo_name
    Environment = var.environment
  }
}