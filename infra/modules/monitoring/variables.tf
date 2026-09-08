variable "name_prefix" {
  description = "Prefix applied to all resource names in this module."
  type        = string
  default     = "assignment"
}

variable "alert_email" {
  description = "Email address to receive SNS alarm notifications. Leave blank to skip creating a subscription (the topic/alarms still get created either way)."
  type        = string
  default     = ""
}

variable "log_retention_days" {
  description = "How long to keep application logs in CloudWatch Logs."
  type        = number
  default     = 14
}

variable "asg_name" {
  description = "Auto Scaling Group name to alarm on (AWS/EC2 CPUUtilization, dimension AutoScalingGroupName)."
  type        = string
}

variable "asg_cpu_high_threshold" {
  description = "CPU utilization percent (average across the ASG) that triggers the high-CPU alarm."
  type        = number
  default     = 80
}

variable "rds_instance_id" {
  description = "RDS DB instance identifier to alarm on (AWS/RDS)."
  type        = string
}

variable "rds_cpu_high_threshold" {
  description = "RDS CPU utilization percent that triggers the high-CPU alarm."
  type        = number
  default     = 80
}

variable "rds_free_storage_threshold_bytes" {
  description = "RDS free storage space (bytes) below which the low-storage alarm fires. Default 2 GiB."
  type        = number
  default     = 2147483648
}

variable "alb_arn_suffix" {
  description = "ALB arn_suffix (short form used by CloudWatch metric dimensions, e.g. app/assignment-alb/abc123)."
  type        = string
}

variable "target_group_arn_suffix" {
  description = "Target group arn_suffix (short form used by CloudWatch metric dimensions, e.g. targetgroup/assignment-tg/abc123)."
  type        = string
}