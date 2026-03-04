output "documentdb_security_group_id" {
  description = "Security group ID for DocumentDB"
  value       = aws_security_group.documentdb.id
}

output "documentdb_subnet_group_name" {
  description = "Subnet group name for DocumentDB"
  value       = aws_docdb_subnet_group.this.name
}
