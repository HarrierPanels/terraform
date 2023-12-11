output "efs_dns_name" {
  value = aws_efs_file_system.myefs.dns_name
}

output "rds_endpoint" {
  value = aws_db_instance.mysql.endpoint
}
