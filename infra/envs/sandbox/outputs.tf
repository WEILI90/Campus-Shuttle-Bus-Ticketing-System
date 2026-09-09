output "alb_dns_name" {
  description = "Public URL to reach the app through (http://<this>)."
  value       = module.alb.alb_dns_name
}

output "rds_endpoint" {
  value     = module.rds.db_endpoint
  sensitive = true
}

output "s3_bucket_name" {
  value = module.s3.bucket_id
}

output "secret_arn" {
  value = module.secrets.secret_arn
}

output "asg_name" {
  value = module.asg.asg_name
}
output "sns_topic_arn" {
  description = "SNS topic every CloudWatch alarm publishes to. Subscribe additional endpoints here if needed."
  value       = module.monitoring.sns_topic_arn
}

output "log_group_name" {
  description = "CloudWatch Logs group holding Apache access/error logs from every app instance."
  value       = module.monitoring.log_group_name
}

output "dashboard_name" {
  description = "CloudWatch dashboard name - view at console.aws.amazon.com > CloudWatch > Dashboards."
  value       = module.monitoring.dashboard_name
}
