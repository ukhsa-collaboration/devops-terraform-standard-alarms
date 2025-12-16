variable "project_tag_key" {
  description = "Tag key used to identify project resources for alarm discovery."
  type        = string
  default     = "lz:Service"

  validation {
    condition     = length(trimspace(var.project_tag_key)) > 0
    error_message = "project_tag_key must be a non-empty string."
  }
}

variable "project_tag_value" {
  description = "Tag value used to identify project resources for alarm discovery."
  type        = string
  default     = null

  validation {
    condition     = var.project_tag_value == null || length(trimspace(var.project_tag_value)) > 0
    error_message = "project_tag_value must be null or a non-empty string."
  }
}

variable "sns_topic_arn" {
  description = "SNS topic ARN used for all CloudWatch alarm actions."
  type        = string
  default     = null
}

variable "enable_sns_volume_alarms" {
  description = "Whether to enable SNS delivery volume alarms."
  type        = bool
  default     = false
}

variable "enable_sns_publish_alarms" {
  description = "Whether to enable SNS NumberOfMessagesPublished alarms."
  type        = bool
  default     = false
}

variable "sns_topic_alarm_config" {
  description = "Per-SNS-topic delivery alarm configuration keyed by topic ARN."
  type = map(object({
    enabled        = bool
    min_deliveries = number
  }))
  default = {}
}

variable "sns_enable_anomaly_detection" {
  description = "Enable anomaly detection for SNS delivery volume alarms."
  type        = bool
  default     = false
}

variable "enable_sns_failure_alarms" {
  description = "Whether to enable SNS NumberOfNotificationsFailed alarms."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to all CloudWatch alarms created by the module."
  type        = map(string)
  default     = {}
}

variable "alarm_schedule" {
  description = "When alarms should evaluate. Use \"OfficeHours\" for Mon-Fri 09:00-17:00 UTC, otherwise alarms stay enabled 24x7."
  type        = string
  default     = "24x7"

  validation {
    condition     = var.alarm_schedule == "OfficeHours" || var.alarm_schedule == "24x7"
    error_message = "alarm_schedule must be either \"24x7\" or \"OfficeHours\"."
  }
}

variable "ecs_cpu_utilization_threshold" {
  description = "Threshold for ECS service CPUUtilization alarms."
  type        = number
  default     = 80

  validation {
    condition     = var.ecs_cpu_utilization_threshold > 0 && var.ecs_cpu_utilization_threshold <= 100
    error_message = "ecs_cpu_utilization_threshold must be between 1 and 100 percent."
  }
}

variable "ecs_memory_utilization_threshold" {
  description = "Threshold for ECS service MemoryUtilization alarms."
  type        = number
  default     = 80

  validation {
    condition     = var.ecs_memory_utilization_threshold > 0 && var.ecs_memory_utilization_threshold <= 100
    error_message = "ecs_memory_utilization_threshold must be between 1 and 100 percent."
  }
}

variable "lambda_claimed_account_concurrency_threshold" {
  description = "Threshold for the account-level ClaimedAccountConcurrency alarm."
  type        = number
  default     = 900

  validation {
    condition     = var.lambda_claimed_account_concurrency_threshold >= 0
    error_message = "lambda_claimed_account_concurrency_threshold must be greater than or equal to 0."
  }
}

variable "lambda_concurrent_executions_threshold" {
  description = "Threshold for Lambda ConcurrentExecutions alarms."
  type        = number
  default     = 900

  validation {
    condition     = var.lambda_concurrent_executions_threshold >= 0
    error_message = "lambda_concurrent_executions_threshold must be greater than or equal to 0."
  }
}

variable "lambda_duration_threshold" {
  description = "Threshold for Lambda Duration alarms in milliseconds."
  type        = number
  default     = 1000

  validation {
    condition     = var.lambda_duration_threshold > 0
    error_message = "lambda_duration_threshold must be greater than 0 milliseconds."
  }
}

variable "lambda_errors_threshold" {
  description = "Threshold for Lambda Errors alarms."
  type        = number
  default     = 1

  validation {
    condition     = var.lambda_errors_threshold >= 0
    error_message = "lambda_errors_threshold must be greater than or equal to 0."
  }
}

variable "lambda_throttles_threshold" {
  description = "Threshold for Lambda Throttles alarms."
  type        = number
  default     = 1

  validation {
    condition     = var.lambda_throttles_threshold >= 0
    error_message = "lambda_throttles_threshold must be greater than or equal to 0."
  }
}

variable "cloudfront_5xx_error_rate_threshold" {
  description = "Threshold for CloudFront 5xxErrorRate alarms."
  type        = number
  default     = 1

  validation {
    condition     = var.cloudfront_5xx_error_rate_threshold >= 0 && var.cloudfront_5xx_error_rate_threshold <= 100
    error_message = "cloudfront_5xx_error_rate_threshold must be between 0 and 100 percent."
  }
}

variable "cloudfront_origin_latency_threshold" {
  description = "Threshold for CloudFront OriginLatency alarms."
  type        = number
  default     = 500

  validation {
    condition     = var.cloudfront_origin_latency_threshold > 0
    error_message = "cloudfront_origin_latency_threshold must be greater than 0 milliseconds."
  }
}

variable "waf_blocked_requests_threshold" {
  description = "Threshold for WAFv2 BlockedRequests alarms."
  type        = number
  default     = 100

  validation {
    condition     = var.waf_blocked_requests_threshold >= 0
    error_message = "waf_blocked_requests_threshold must be greater than or equal to 0."
  }
}

variable "rds_buffer_cache_hit_ratio_threshold" {
  description = "Threshold for RDS BufferCacheHitRatio alarms."
  type        = number
  default     = 80

  validation {
    condition     = var.rds_buffer_cache_hit_ratio_threshold >= 0 && var.rds_buffer_cache_hit_ratio_threshold <= 100
    error_message = "rds_buffer_cache_hit_ratio_threshold must be between 0 and 100 percent."
  }
}

variable "rds_cpu_utilization_threshold" {
  description = "Threshold for RDS CPUUtilization alarms."
  type        = number
  default     = 90

  validation {
    condition     = var.rds_cpu_utilization_threshold > 0 && var.rds_cpu_utilization_threshold <= 100
    error_message = "rds_cpu_utilization_threshold must be between 1 and 100 percent."
  }
}

variable "rds_database_connections_threshold" {
  description = "Threshold for RDS DatabaseConnections alarms."
  type        = number
  default     = 1000

  validation {
    condition     = var.rds_database_connections_threshold >= 0
    error_message = "rds_database_connections_threshold must be greater than or equal to 0."
  }
}

variable "rds_db_load_threshold" {
  description = "Threshold for RDS DBLoad alarms."
  type        = number
  default     = 4

  validation {
    condition     = var.rds_db_load_threshold >= 0
    error_message = "rds_db_load_threshold must be greater than or equal to 0."
  }
}

variable "rds_freeable_memory_threshold" {
  description = "Threshold for RDS FreeableMemory alarms."
  type        = number
  default     = 500000000

  validation {
    condition     = var.rds_freeable_memory_threshold >= 0
    error_message = "rds_freeable_memory_threshold must be greater than or equal to 0 bytes."
  }
}

variable "rds_maximum_used_transaction_ids_threshold" {
  description = "Threshold for RDS MaximumUsedTransactionIDs alarms."
  type        = number
  default     = 1000000000

  validation {
    condition     = var.rds_maximum_used_transaction_ids_threshold >= 0
    error_message = "rds_maximum_used_transaction_ids_threshold must be greater than or equal to 0."
  }
}

variable "rds_read_latency_threshold" {
  description = "Threshold for RDS ReadLatency alarms."
  type        = number
  default     = 20

  validation {
    condition     = var.rds_read_latency_threshold >= 0
    error_message = "rds_read_latency_threshold must be greater than or equal to 0 milliseconds."
  }
}

variable "rds_storage_network_throughput_threshold" {
  description = "Threshold for RDS StorageNetworkThroughput alarms."
  type        = number
  default     = 10000000

  validation {
    condition     = var.rds_storage_network_throughput_threshold >= 0
    error_message = "rds_storage_network_throughput_threshold must be greater than or equal to 0 bytes per second."
  }
}

variable "rds_write_latency_threshold" {
  description = "Threshold for RDS WriteLatency alarms."
  type        = number
  default     = 20

  validation {
    condition     = var.rds_write_latency_threshold >= 0
    error_message = "rds_write_latency_threshold must be greater than or equal to 0 milliseconds."
  }
}

variable "alb_target_5xx_threshold" {
  description = "Threshold for ALB HTTPCode_Target_5XX_Count alarms."
  type        = number
  default     = 5

  validation {
    condition     = var.alb_target_5xx_threshold >= 0
    error_message = "alb_target_5xx_threshold must be greater than or equal to 0."
  }
}

variable "alb_target_response_time_threshold" {
  description = "Threshold for ALB TargetResponseTime alarms in seconds."
  type        = number
  default     = 0.75

  validation {
    condition     = var.alb_target_response_time_threshold > 0
    error_message = "alb_target_response_time_threshold must be greater than 0 seconds."
  }
}

variable "elasticache_cpu_utilization_threshold" {
  description = "Threshold for ElastiCache CPUUtilization alarms."
  type        = number
  default     = 90

  validation {
    condition     = var.elasticache_cpu_utilization_threshold > 0 && var.elasticache_cpu_utilization_threshold <= 100
    error_message = "elasticache_cpu_utilization_threshold must be between 1 and 100 percent."
  }
}

variable "elasticache_curr_connections_threshold" {
  description = "Threshold for ElastiCache CurrConnections alarms."
  type        = number
  default     = 50000

  validation {
    condition     = var.elasticache_curr_connections_threshold >= 0
    error_message = "elasticache_curr_connections_threshold must be greater than or equal to 0."
  }
}

variable "elasticache_database_memory_usage_percentage_threshold" {
  description = "Threshold for ElastiCache DatabaseMemoryUsagePercentage alarms."
  type        = number
  default     = 90

  validation {
    condition     = var.elasticache_database_memory_usage_percentage_threshold > 0 && var.elasticache_database_memory_usage_percentage_threshold <= 100
    error_message = "elasticache_database_memory_usage_percentage_threshold must be between 1 and 100 percent."
  }
}

variable "elasticache_engine_cpu_utilization_threshold" {
  description = "Threshold for ElastiCache EngineCPUUtilization alarms."
  type        = number
  default     = 90

  validation {
    condition     = var.elasticache_engine_cpu_utilization_threshold > 0 && var.elasticache_engine_cpu_utilization_threshold <= 100
    error_message = "elasticache_engine_cpu_utilization_threshold must be between 1 and 100 percent."
  }
}

variable "elasticache_replication_lag_threshold" {
  description = "Threshold for ElastiCache ReplicationLag alarms."
  type        = number
  default     = 30

  validation {
    condition     = var.elasticache_replication_lag_threshold >= 0
    error_message = "elasticache_replication_lag_threshold must be greater than or equal to 0 seconds."
  }
}

variable "sqs_age_of_oldest_message_threshold" {
  description = "Threshold for SQS ApproximateAgeOfOldestMessage alarms in seconds."
  type        = number
  default     = 300

  validation {
    condition     = var.sqs_age_of_oldest_message_threshold >= 0
    error_message = "sqs_age_of_oldest_message_threshold must be greater than or equal to 0 seconds."
  }
}

variable "sqs_messages_not_visible_threshold" {
  description = "Threshold for SQS ApproximateNumberOfMessagesNotVisible alarms."
  type        = number
  default     = 10000

  validation {
    condition     = var.sqs_messages_not_visible_threshold >= 0
    error_message = "sqs_messages_not_visible_threshold must be greater than or equal to 0."
  }
}

variable "sqs_messages_visible_threshold" {
  description = "Threshold for SQS ApproximateNumberOfMessagesVisible alarms."
  type        = number
  default     = 5000

  validation {
    condition     = var.sqs_messages_visible_threshold >= 0
    error_message = "sqs_messages_visible_threshold must be greater than or equal to 0."
  }
}

variable "sqs_number_of_messages_sent_threshold" {
  description = "Threshold for SQS NumberOfMessagesSent alarms."
  type        = number
  default     = 0

  validation {
    condition     = var.sqs_number_of_messages_sent_threshold >= 0
    error_message = "sqs_number_of_messages_sent_threshold must be greater than or equal to 0."
  }
}

variable "enable_sqs_producer_alarms" {
  description = "Whether to enable SQS producer (NumberOfMessagesSent) alarms."
  type        = bool
  default     = false
}

variable "certificate_days_to_expiry_threshold" {
  description = "Threshold for ACM certificate expiry alarms in days."
  type        = number
  default     = 44

  validation {
    condition     = var.certificate_days_to_expiry_threshold > 0 && var.certificate_days_to_expiry_threshold <= 365
    error_message = "certificate_days_to_expiry_threshold must be between 1 and 365 days."
  }
}

variable "natgateway_error_port_allocation_threshold" {
  description = "Threshold for NAT Gateway ErrorPortAllocation alarms."
  type        = number
  default     = 0

  validation {
    condition     = var.natgateway_error_port_allocation_threshold >= 0
    error_message = "natgateway_error_port_allocation_threshold must be greater than or equal to 0."
  }
}

variable "natgateway_packets_drop_count_threshold" {
  description = "Threshold for NAT Gateway PacketsDropCount alarms."
  type        = number
  default     = 100

  validation {
    condition     = var.natgateway_packets_drop_count_threshold >= 0
    error_message = "natgateway_packets_drop_count_threshold must be greater than or equal to 0."
  }
}

variable "sns_messages_published_threshold" {
  description = "Threshold for SNS NumberOfMessagesPublished alarms."
  type        = number
  default     = 1

  validation {
    condition     = var.sns_messages_published_threshold >= 0
    error_message = "sns_messages_published_threshold must be greater than or equal to 0."
  }
}

variable "sns_notifications_failed_threshold" {
  description = "Threshold for SNS NumberOfNotificationsFailed alarms."
  type        = number
  default     = 1

  validation {
    condition     = var.sns_notifications_failed_threshold >= 0
    error_message = "sns_notifications_failed_threshold must be greater than or equal to 0."
  }
}

variable "office_hours_buffer_minutes" {
  description = "Buffer time in minutes before/after office hours to prevent startup/shutdown alarms."
  type        = number
  default     = 5

  validation {
    condition     = var.office_hours_buffer_minutes >= 0 && var.office_hours_buffer_minutes <= 30
    error_message = "office_hours_buffer_minutes must be between 0 and 30 minutes."
  }
}
