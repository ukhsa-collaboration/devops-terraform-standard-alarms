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

variable "tags" {
  description = "Tags applied to all CloudWatch alarms created by the module."
  type        = map(string)
  default     = {}
}

variable "ecs_cpu_utilization_threshold" {
  description = "Threshold for ECS service CPUUtilization alarms."
  type        = number
  default     = 80
}

variable "ecs_memory_utilization_threshold" {
  description = "Threshold for ECS service MemoryUtilization alarms."
  type        = number
  default     = 80
}

variable "lambda_claimed_account_concurrency_threshold" {
  description = "Threshold for the account-level ClaimedAccountConcurrency alarm."
  type        = number
  default     = 900
}

variable "lambda_concurrent_executions_threshold" {
  description = "Threshold for Lambda ConcurrentExecutions alarms."
  type        = number
  default     = 900
}

variable "lambda_duration_threshold" {
  description = "Threshold for Lambda Duration alarms in milliseconds."
  type        = number
  default     = 1000
}

variable "lambda_errors_threshold" {
  description = "Threshold for Lambda Errors alarms."
  type        = number
  default     = 1
}

variable "lambda_throttles_threshold" {
  description = "Threshold for Lambda Throttles alarms."
  type        = number
  default     = 1
}

variable "cloudfront_5xx_error_rate_threshold" {
  description = "Threshold for CloudFront 5xxErrorRate alarms."
  type        = number
  default     = 1
}

variable "cloudfront_origin_latency_threshold" {
  description = "Threshold for CloudFront OriginLatency alarms."
  type        = number
  default     = 500
}

variable "waf_blocked_requests_threshold" {
  description = "Threshold for WAFv2 BlockedRequests alarms."
  type        = number
  default     = 100
}

variable "rds_buffer_cache_hit_ratio_threshold" {
  description = "Threshold for RDS BufferCacheHitRatio alarms."
  type        = number
  default     = 80
}

variable "rds_cpu_utilization_threshold" {
  description = "Threshold for RDS CPUUtilization alarms."
  type        = number
  default     = 90
}

variable "rds_database_connections_threshold" {
  description = "Threshold for RDS DatabaseConnections alarms."
  type        = number
  default     = 1000
}

variable "rds_db_load_threshold" {
  description = "Threshold for RDS DBLoad alarms."
  type        = number
  default     = 4
}

variable "rds_freeable_memory_threshold" {
  description = "Threshold for RDS FreeableMemory alarms."
  type        = number
  default     = 500000000
}

variable "rds_maximum_used_transaction_ids_threshold" {
  description = "Threshold for RDS MaximumUsedTransactionIDs alarms."
  type        = number
  default     = 1000000000
}

variable "rds_read_latency_threshold" {
  description = "Threshold for RDS ReadLatency alarms."
  type        = number
  default     = 20
}

variable "rds_storage_network_throughput_threshold" {
  description = "Threshold for RDS StorageNetworkThroughput alarms."
  type        = number
  default     = 10000000
}

variable "rds_write_latency_threshold" {
  description = "Threshold for RDS WriteLatency alarms."
  type        = number
  default     = 20
}

variable "alb_target_5xx_threshold" {
  description = "Threshold for ALB HTTPCode_Target_5XX_Count alarms."
  type        = number
  default     = 5
}

variable "alb_target_response_time_threshold" {
  description = "Threshold for ALB TargetResponseTime alarms in seconds."
  type        = number
  default     = 0.75
}

variable "elasticache_cpu_utilization_threshold" {
  description = "Threshold for ElastiCache CPUUtilization alarms."
  type        = number
  default     = 90
}

variable "elasticache_curr_connections_threshold" {
  description = "Threshold for ElastiCache CurrConnections alarms."
  type        = number
  default     = 50000
}

variable "elasticache_database_memory_usage_percentage_threshold" {
  description = "Threshold for ElastiCache DatabaseMemoryUsagePercentage alarms."
  type        = number
  default     = 90
}

variable "elasticache_engine_cpu_utilization_threshold" {
  description = "Threshold for ElastiCache EngineCPUUtilization alarms."
  type        = number
  default     = 90
}

variable "elasticache_replication_lag_threshold" {
  description = "Threshold for ElastiCache ReplicationLag alarms."
  type        = number
  default     = 30
}

variable "sqs_age_of_oldest_message_threshold" {
  description = "Threshold for SQS ApproximateAgeOfOldestMessage alarms in seconds."
  type        = number
  default     = 300
}

variable "sqs_messages_not_visible_threshold" {
  description = "Threshold for SQS ApproximateNumberOfMessagesNotVisible alarms."
  type        = number
  default     = 10000
}

variable "sqs_messages_visible_threshold" {
  description = "Threshold for SQS ApproximateNumberOfMessagesVisible alarms."
  type        = number
  default     = 5000
}

variable "sqs_number_of_messages_sent_threshold" {
  description = "Threshold for SQS NumberOfMessagesSent alarms."
  type        = number
  default     = 0
}
