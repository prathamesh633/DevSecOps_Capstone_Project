# ── DB Subnet Group ──────────────────────────────────────────────────────────
resource "aws_db_subnet_group" "main" {
  name       = "${var.cluster_name}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id
  tags       = { Name = "${var.cluster_name}-db-subnet-group" }
}

# ── RDS Parameter Group ──────────────────────────────────────────────────────
resource "aws_db_parameter_group" "postgres" {
  name   = "${var.cluster_name}-pg-params"
  family = "postgres15"

  parameter {
    name  = "log_connections"
    value = "1"
  }
  parameter {
    name  = "log_disconnections"
    value = "1"
  }
}

# ── RDS PostgreSQL Instance ──────────────────────────────────────────────────
# tfsec:ignore:aws-rds-aws0176
# tfsec:ignore:aws-rds-aws0177
# tfsec:ignore:aws-rds-enable-performance-insights
resource "aws_db_instance" "postgres" {
  # checkov:skip=CKV_AWS_161:IAM Auth not required for demo
  # checkov:skip=CKV_AWS_157:Multi-AZ not required for demo
  # checkov:skip=CKV_AWS_118:Enhanced Monitoring not required for demo
  # checkov:skip=CKV_AWS_226:Minor upgrades auto not required for demo
  # checkov:skip=CKV_AWS_293:Deletion protection not required for demo
  # checkov:skip=CKV_AWS_353:Performance insights not required for demo
  # checkov:skip=CKV2_AWS_60:Copy tags to snapshots not required for demo
  # checkov:skip=CKV2_AWS_69:Encryption in transit not required for demo
  identifier        = "${var.cluster_name}-postgres"
  engine            = "postgres"
  engine_version    = "15"
  instance_class    = var.db_instance_class
  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.postgres.name

  # High availability
  multi_az = var.environment == "prod" ? true : false

  # Backups — set to 0 for AWS Free Tier compatibility
  backup_retention_period = 0
  maintenance_window      = "Mon:04:00-Mon:05:00"

  # Security
  publicly_accessible       = false
  deletion_protection       = var.environment == "prod" ? true : false
  skip_final_snapshot       = var.environment != "prod"
  final_snapshot_identifier = "${var.cluster_name}-postgres-final"

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  tags = { Name = "${var.cluster_name}-postgres" }
}
