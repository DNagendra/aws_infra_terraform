#OUTPUT RDS INSTANCE END POINT

output "rds-end-point" {
  value = aws_db_instance.rds-db-resource.endpoint
}

output "rds-database-name" {
  value = aws_db_instance.rds-db-resource.name
  
}
