# ================================
# 🔍 Obter VPC e subnets default
# ================================
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# ================================
# 🔐 Ler segredo do Secrets Manager
# ================================
data "aws_secretsmanager_secret" "rds_secret" {
  name = var.secret_name
}

data "aws_secretsmanager_secret_version" "rds_secret_value" {
  secret_id = data.aws_secretsmanager_secret.rds_secret.id
}

locals {
  db_credentials = jsondecode(data.aws_secretsmanager_secret_version.rds_secret_value.secret_string)
}

# ================================
# 🛡️ Security Group do RDS
# ================================
resource "aws_security_group" "rds_sg" {
  name        = "rds-${var.environment}-sg"
  description = "SG do RDS (${var.environment})"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Permite acesso MySQL interno"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # rede interna default
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "rds-${var.environment}-sg"
    Environment = var.environment
  }
}

# ================================
# 🗄️ Subnet Group do RDS
# ================================
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-${var.environment}-subnet-group"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Name        = "rds-${var.environment}-subnet-group"
    Environment = var.environment
  }
}

# ================================
# 💾 Instância RDS MariaDB
# ================================
resource "aws_db_instance" "rds_instance" {
  identifier               = "rds-${var.environment}-mariadb"
  engine                   = "mariadb"
  #engine_version          = var.engine_version

  instance_class           = var.instance_class
  allocated_storage        = var.allocated_storage
  storage_encrypted        = true

  db_name                  = var.db_name
  username                 = local.db_credentials.username
  password                 = local.db_credentials.password

  db_subnet_group_name     = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids   = [aws_security_group.rds_sg.id]

  publicly_accessible              = false
  backup_retention_period          = var.backup_retention_period
  
  deletion_protection              = true
  skip_final_snapshot              = false
  multi_az                         = false

  tags = {
    Name        = "rds-${var.environment}-mariadb"
    Project     = var.project
    Owner       = var.owner
    Environment = var.environment
  }
}


