resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name        = "${var.environment}-db-subnet-group"
    Environment = var.environment
  }
}

resource "aws_db_instance" "rds_instance" {
  identifier        = "${var.instance_identifier}-${var.environment}-db-instance"
  engine            = "mariadb"
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [var.db_sg_id]

  publicly_accessible     = true
  backup_retention_period = var.backup_retention_period
  deletion_protection     = false
  skip_final_snapshot     = true
  multi_az                = false

  tags = {
    Name        = "${var.instance_identifier}-${var.environment}-db-instance"
    Environment = var.environment
  }
}