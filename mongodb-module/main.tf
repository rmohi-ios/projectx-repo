# DocumentDB Module

# Random password for DocumentDB admin user
resource "random_password" "docdb_password" {
  length  = 16
  special = false
}

# Random suffix for unique resource names
resource "random_id" "suffix" {
  byte_length = 3
}

# Secrets Manager secret to store DocumentDB credentials
resource "aws_secretsmanager_secret" "docdb" {
  name        = "${var.name_prefix}-${var.environment}-docdb-secret-${random_id.suffix.hex}"
  description = "DocumentDB credentials for ${var.environment} environment"
  tags        = var.tags_proshop
}

# Add a version of the secret with actual credentials
resource "aws_secretsmanager_secret_version" "docdb" {
  secret_id = aws_secretsmanager_secret.docdb.id

  secret_string = jsonencode({
    username  = var.master_username
    password  = random_password.docdb_password.result
    engine    = "documentdb"
    host      = aws_docdb_cluster.this.endpoint
    port      = 27017
    MONGO_URI = "mongodb://proshop_admin:${random_password.docdb_password.result}@${aws_docdb_cluster.this.endpoint}:27017/?replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false&directConnection=true"
  })
}

#Custom parameter group for DocumentDB
resource "aws_docdb_cluster_parameter_group" "docdb_tls_disabled" {
  name        = "${var.name_prefix}-${var.environment}-docdb-param-group"
  family      = "docdb5.0"
  description = "Parameter group with TLS disabled for DocumentDB"

  parameter {
    name  = "tls"
    value = "disabled"
  }

  tags = var.tags_proshop
}

# DocumentDB Cluster
resource "aws_docdb_cluster" "this" {
  cluster_identifier              = "${var.name_prefix}-${var.environment}-docdb-cluster"
  engine                          = "docdb"
  engine_version                  = "5.0.0"
  master_username                 = var.master_username
  master_password                 = random_password.docdb_password.result
  db_subnet_group_name            = aws_docdb_subnet_group.this.name
  vpc_security_group_ids          = [aws_security_group.documentdb.id]
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.docdb_tls_disabled.name
  skip_final_snapshot             = true
  apply_immediately               = true
  storage_encrypted               = false
}

# DocumentDB Cluster Instances
resource "aws_docdb_cluster_instance" "this" {
  count              = var.instance_count
  identifier         = "${var.name_prefix}-${var.environment}-docdb-instance-${count.index + 1}"
  cluster_identifier = aws_docdb_cluster.this.id
  instance_class     = var.mongo_db_instance_class
  apply_immediately  = true
}
