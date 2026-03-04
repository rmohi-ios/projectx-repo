# Locals 
locals {
  documentdb_port = 27017
}

#Secutity Group for DocumentDB
resource "aws_security_group" "documentdb" {
  name        = "${var.name_prefix}-documentdb-sg"
  description = "Security group for DocumentDB cluster"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow MongoDB traffic from EKS nodes"
    from_port       = local.documentdb_port
    to_port         = local.documentdb_port
    protocol        = "tcp"
    security_groups = [var.node_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags_proshop, {
    Name = "${var.name_prefix}-documentdb-sg"
  })
}

#DocumentDb Subnet Group
resource "aws_docdb_subnet_group" "this" {
  name       = "${var.name_prefix}-${var.environment}-docdb-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags_proshop, {
    Name = "${var.name_prefix}-docdb-subnet-group"
  })
}

