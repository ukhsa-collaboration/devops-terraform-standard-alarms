locals {
  ecs_alarm_arns = concat(
    [for alarm in aws_cloudwatch_metric_alarm.ecs_cpu : alarm.arn],
    [for alarm in aws_cloudwatch_metric_alarm.ecs_memory : alarm.arn],
  )

  lambda_alarm_arns = concat(
    aws_cloudwatch_metric_alarm.lambda_claimed_account_concurrency[*].arn,
    [for alarm in aws_cloudwatch_metric_alarm.lambda_concurrent_executions : alarm.arn],
    [for alarm in aws_cloudwatch_metric_alarm.lambda_duration : alarm.arn],
    [for alarm in aws_cloudwatch_metric_alarm.lambda_errors : alarm.arn],
    [for alarm in aws_cloudwatch_metric_alarm.lambda_throttles : alarm.arn],
  )

  cloudfront_alarm_arns = concat(
    [for alarm in aws_cloudwatch_metric_alarm.cloudfront_5xx_error_rate : alarm.arn],
    [for alarm in aws_cloudwatch_metric_alarm.cloudfront_origin_latency : alarm.arn],
  )

  alb_alarm_arns = concat(
    [for alarm in aws_cloudwatch_metric_alarm.alb_target_5xx : alarm.arn],
    [for alarm in aws_cloudwatch_metric_alarm.alb_target_response_time : alarm.arn],
  )

  waf_alarm_arns = [for alarm in aws_cloudwatch_metric_alarm.waf_blocked_requests : alarm.arn]

  rds_alarm_arns = concat(
    [for alarm in aws_cloudwatch_metric_alarm.rds_buffer_cache_hit_ratio : alarm.arn],
    [for alarm in aws_cloudwatch_metric_alarm.rds_cpu_utilization : alarm.arn],
    [for alarm in aws_cloudwatch_metric_alarm.rds_database_connections : alarm.arn],
    [for alarm in aws_cloudwatch_metric_alarm.rds_db_load : alarm.arn],
    [for alarm in aws_cloudwatch_metric_alarm.rds_engine_uptime : alarm.arn],
    [for alarm in aws_cloudwatch_metric_alarm.rds_freeable_memory : alarm.arn],
    [for alarm in aws_cloudwatch_metric_alarm.rds_maximum_used_transaction_ids : alarm.arn],
    [for alarm in aws_cloudwatch_metric_alarm.rds_read_latency : alarm.arn],
    [for alarm in aws_cloudwatch_metric_alarm.rds_storage_network_throughput : alarm.arn],
    [for alarm in aws_cloudwatch_metric_alarm.rds_write_latency : alarm.arn],
  )

  elasticache_alarm_arns = concat(
    [for alarm in aws_cloudwatch_metric_alarm.cpu_utilization : alarm.arn],
    [for alarm in aws_cloudwatch_metric_alarm.curr_connections : alarm.arn],
    [for alarm in aws_cloudwatch_metric_alarm.database_memory_usage_percentage : alarm.arn],
    [for alarm in aws_cloudwatch_metric_alarm.engine_cpu_utilization : alarm.arn],
    [for alarm in aws_cloudwatch_metric_alarm.replication_lag : alarm.arn],
  )

  natgateway_alarm_arns = concat(
    [for alarm in aws_cloudwatch_metric_alarm.error_port_allocation : alarm.arn],
    [for alarm in aws_cloudwatch_metric_alarm.packets_drop_count : alarm.arn],
  )

  sqs_alarm_arns = concat(
    [for alarm in aws_cloudwatch_metric_alarm.approximate_age_of_oldest_message : alarm.arn],
    [for alarm in aws_cloudwatch_metric_alarm.approximate_number_of_messages_not_visible : alarm.arn],
    [for alarm in aws_cloudwatch_metric_alarm.approximate_number_of_messages_visible : alarm.arn],
    [for alarm in aws_cloudwatch_metric_alarm.number_of_messages_sent : alarm.arn],
  )

  sns_alarm_arns = concat(
    [for alarm in aws_cloudwatch_metric_alarm.number_of_messages_published : alarm.arn],
    [for alarm in aws_cloudwatch_metric_alarm.number_of_notifications_delivered : alarm.arn],
    [for alarm in aws_cloudwatch_metric_alarm.number_of_notifications_delivered_anomaly : alarm.arn],
    [for alarm in aws_cloudwatch_metric_alarm.number_of_notifications_failed : alarm.arn],
  )

  acm_alarm_arns = concat(
    [for alarm in aws_cloudwatch_metric_alarm.days_to_expiry : alarm.arn],
    [for alarm in aws_cloudwatch_metric_alarm.days_to_expiry_cdn : alarm.arn],
  )
}

output "all_alarm_arns" {
  description = "All CloudWatch alarms created by the module."
  value       = concat(local.ecs_alarm_arns, local.lambda_alarm_arns, local.cloudfront_alarm_arns, local.alb_alarm_arns, local.waf_alarm_arns, local.rds_alarm_arns, local.elasticache_alarm_arns, local.natgateway_alarm_arns, local.sqs_alarm_arns, local.sns_alarm_arns, local.acm_alarm_arns)
}
