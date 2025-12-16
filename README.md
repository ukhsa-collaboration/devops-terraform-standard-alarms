# Alarms Terraform Module

This module discovers tagged AWS resources and provisions CloudWatch alarms with sensible defaults. By default it uses the SNS topic `aw-phe-<region>-sns-cloudwatch_alarms` in the current account/region, but you can override via `sns_topic_arn`.

## Key Features

### Office Hours Scheduling
Configure alarms to only evaluate during business hours to prevent alerts during expected after-hours scaling:

```hcl
module "alarms" {
  source = "git@github.com:ukhsa-collaboration/devops-terraform-standard-alarms.git"

  # Enable office hours scheduling (Monday-Friday 09:00-17:00 UTC)
  alarm_schedule = "OfficeHours"
}
```

- **24x7 Mode** (default): Alarms evaluate continuously
- **OfficeHours Mode**: Alarms only evaluate Monday-Friday 09:00-17:00 UTC
- **Buffer Time**: Grace period before/after office hours to allow for normal startup/shutdown processes

### Missing Data Treatment Standards
The module applies consistent missing data treatment based on alarm type:

- **Utilization Metrics** (`"missing"`): CPU, memory, connections - missing data typically indicates inactive resources
- **Error/Failure Metrics** (`"notBreaching"`): 5xx errors, failures, latency - missing data usually means no errors (desired state)  
- **Availability/Uptime Metrics** (`"breaching"`): Certificate expiry, uptime - missing data often indicates service problems

### Configurable Thresholds
All alarm thresholds are configurable via variables with validation:

```hcl
module "alarms" {
  source = "git@github.com:ukhsa-collaboration/devops-terraform-standard-alarms.git"

  # ECS thresholds
  ecs_cpu_utilization_threshold    = 85
  ecs_memory_utilization_threshold = 85

  # Lambda thresholds  
  lambda_duration_threshold = 5000
  lambda_errors_threshold   = 2

  # Certificate expiry threshold
  certificate_days_to_expiry_threshold = 30
}
```

## What it does
- Autodiscovery via `aws_resourcegroupstaggingapi_resources` for ECS services, Lambda functions, CloudFront distributions, WAFv2 web ACLs, RDS instances/clusters, ElastiCache clusters, NAT Gateways, SQS queues, SNS topics, and ACM certificates using a configurable tag key/value.
- Creates per-resource CloudWatch alarms with consistent naming `cw-${resource_type}-${resource_name}-${metric}` and configurable thresholds.
- Supports office hours scheduling (Monday-Friday 09:00-17:00 UTC) with configurable buffer time to prevent startup/shutdown false alarms.
- Applies standardized missing data treatment based on alarm type (utilization, error/failure, or availability metrics).
- Sends all alarm actions to the configured SNS topic

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_metric_alarm.alb_target_5xx](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.alb_target_response_time](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.approximate_age_of_oldest_message](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.approximate_number_of_messages_not_visible](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.approximate_number_of_messages_visible](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.cloudfront_5xx_error_rate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.cloudfront_origin_latency](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.cpu_utilization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.curr_connections](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.database_memory_usage_percentage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.days_to_expiry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.days_to_expiry_cdn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.ecs_cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.ecs_memory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.engine_cpu_utilization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.error_port_allocation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.lambda_claimed_account_concurrency](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.lambda_concurrent_executions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.lambda_duration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.lambda_errors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.lambda_throttles](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.number_of_messages_published](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.number_of_messages_sent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.number_of_notifications_delivered](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.number_of_notifications_delivered_anomaly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.number_of_notifications_failed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.packets_drop_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.rds_buffer_cache_hit_ratio](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.rds_cpu_utilization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.rds_database_connections](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.rds_db_load](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.rds_engine_uptime](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.rds_freeable_memory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.rds_maximum_used_transaction_ids](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.rds_read_latency](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.rds_storage_network_throughput](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.rds_write_latency](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.replication_lag](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.waf_blocked_requests](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_elasticache_cluster.discovered](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/elasticache_cluster) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_resourcegroupstaggingapi_resources.acm_certificates](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/resourcegroupstaggingapi_resources) | data source |
| [aws_resourcegroupstaggingapi_resources.acm_certificates_regional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/resourcegroupstaggingapi_resources) | data source |
| [aws_resourcegroupstaggingapi_resources.application_load_balancer_target_groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/resourcegroupstaggingapi_resources) | data source |
| [aws_resourcegroupstaggingapi_resources.application_load_balancers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/resourcegroupstaggingapi_resources) | data source |
| [aws_resourcegroupstaggingapi_resources.cloudfront_distributions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/resourcegroupstaggingapi_resources) | data source |
| [aws_resourcegroupstaggingapi_resources.ecs_services](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/resourcegroupstaggingapi_resources) | data source |
| [aws_resourcegroupstaggingapi_resources.elasticache_clusters](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/resourcegroupstaggingapi_resources) | data source |
| [aws_resourcegroupstaggingapi_resources.lambda_functions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/resourcegroupstaggingapi_resources) | data source |
| [aws_resourcegroupstaggingapi_resources.nat_gateways](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/resourcegroupstaggingapi_resources) | data source |
| [aws_resourcegroupstaggingapi_resources.rds_clusters](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/resourcegroupstaggingapi_resources) | data source |
| [aws_resourcegroupstaggingapi_resources.rds_instances](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/resourcegroupstaggingapi_resources) | data source |
| [aws_resourcegroupstaggingapi_resources.sns_topics](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/resourcegroupstaggingapi_resources) | data source |
| [aws_resourcegroupstaggingapi_resources.sqs_queues](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/resourcegroupstaggingapi_resources) | data source |
| [aws_resourcegroupstaggingapi_resources.wafv2_web_acls](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/resourcegroupstaggingapi_resources) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_schedule"></a> [alarm\_schedule](#input\_alarm\_schedule) | When alarms should evaluate. Use "OfficeHours" for Mon-Fri 09:00-17:00 UTC, otherwise alarms stay enabled 24x7. | `string` | `"24x7"` | no |
| <a name="input_alb_target_5xx_threshold"></a> [alb\_target\_5xx\_threshold](#input\_alb\_target\_5xx\_threshold) | Threshold for ALB HTTPCode\_Target\_5XX\_Count alarms. | `number` | `5` | no |
| <a name="input_alb_target_response_time_threshold"></a> [alb\_target\_response\_time\_threshold](#input\_alb\_target\_response\_time\_threshold) | Threshold for ALB TargetResponseTime alarms in seconds. | `number` | `0.75` | no |
| <a name="input_certificate_days_to_expiry_threshold"></a> [certificate\_days\_to\_expiry\_threshold](#input\_certificate\_days\_to\_expiry\_threshold) | Threshold for ACM certificate expiry alarms in days. | `number` | `44` | no |
| <a name="input_cloudfront_5xx_error_rate_threshold"></a> [cloudfront\_5xx\_error\_rate\_threshold](#input\_cloudfront\_5xx\_error\_rate\_threshold) | Threshold for CloudFront 5xxErrorRate alarms. | `number` | `1` | no |
| <a name="input_cloudfront_origin_latency_threshold"></a> [cloudfront\_origin\_latency\_threshold](#input\_cloudfront\_origin\_latency\_threshold) | Threshold for CloudFront OriginLatency alarms. | `number` | `500` | no |
| <a name="input_ecs_cpu_utilization_threshold"></a> [ecs\_cpu\_utilization\_threshold](#input\_ecs\_cpu\_utilization\_threshold) | Threshold for ECS service CPUUtilization alarms. | `number` | `80` | no |
| <a name="input_ecs_memory_utilization_threshold"></a> [ecs\_memory\_utilization\_threshold](#input\_ecs\_memory\_utilization\_threshold) | Threshold for ECS service MemoryUtilization alarms. | `number` | `80` | no |
| <a name="input_elasticache_cpu_utilization_threshold"></a> [elasticache\_cpu\_utilization\_threshold](#input\_elasticache\_cpu\_utilization\_threshold) | Threshold for ElastiCache CPUUtilization alarms. | `number` | `90` | no |
| <a name="input_elasticache_curr_connections_threshold"></a> [elasticache\_curr\_connections\_threshold](#input\_elasticache\_curr\_connections\_threshold) | Threshold for ElastiCache CurrConnections alarms. | `number` | `50000` | no |
| <a name="input_elasticache_database_memory_usage_percentage_threshold"></a> [elasticache\_database\_memory\_usage\_percentage\_threshold](#input\_elasticache\_database\_memory\_usage\_percentage\_threshold) | Threshold for ElastiCache DatabaseMemoryUsagePercentage alarms. | `number` | `90` | no |
| <a name="input_elasticache_engine_cpu_utilization_threshold"></a> [elasticache\_engine\_cpu\_utilization\_threshold](#input\_elasticache\_engine\_cpu\_utilization\_threshold) | Threshold for ElastiCache EngineCPUUtilization alarms. | `number` | `90` | no |
| <a name="input_elasticache_replication_lag_threshold"></a> [elasticache\_replication\_lag\_threshold](#input\_elasticache\_replication\_lag\_threshold) | Threshold for ElastiCache ReplicationLag alarms. | `number` | `30` | no |
| <a name="input_enable_sns_failure_alarms"></a> [enable\_sns\_failure\_alarms](#input\_enable\_sns\_failure\_alarms) | Whether to enable SNS NumberOfNotificationsFailed alarms. | `bool` | `false` | no |
| <a name="input_enable_sns_publish_alarms"></a> [enable\_sns\_publish\_alarms](#input\_enable\_sns\_publish\_alarms) | Whether to enable SNS NumberOfMessagesPublished alarms. | `bool` | `false` | no |
| <a name="input_enable_sns_volume_alarms"></a> [enable\_sns\_volume\_alarms](#input\_enable\_sns\_volume\_alarms) | Whether to enable SNS delivery volume alarms. | `bool` | `false` | no |
| <a name="input_enable_sqs_producer_alarms"></a> [enable\_sqs\_producer\_alarms](#input\_enable\_sqs\_producer\_alarms) | Whether to enable SQS producer (NumberOfMessagesSent) alarms. | `bool` | `false` | no |
| <a name="input_lambda_claimed_account_concurrency_threshold"></a> [lambda\_claimed\_account\_concurrency\_threshold](#input\_lambda\_claimed\_account\_concurrency\_threshold) | Threshold for the account-level ClaimedAccountConcurrency alarm. | `number` | `900` | no |
| <a name="input_lambda_concurrent_executions_threshold"></a> [lambda\_concurrent\_executions\_threshold](#input\_lambda\_concurrent\_executions\_threshold) | Threshold for Lambda ConcurrentExecutions alarms. | `number` | `900` | no |
| <a name="input_lambda_duration_threshold"></a> [lambda\_duration\_threshold](#input\_lambda\_duration\_threshold) | Threshold for Lambda Duration alarms in milliseconds. | `number` | `1000` | no |
| <a name="input_lambda_errors_threshold"></a> [lambda\_errors\_threshold](#input\_lambda\_errors\_threshold) | Threshold for Lambda Errors alarms. | `number` | `1` | no |
| <a name="input_lambda_throttles_threshold"></a> [lambda\_throttles\_threshold](#input\_lambda\_throttles\_threshold) | Threshold for Lambda Throttles alarms. | `number` | `1` | no |
| <a name="input_natgateway_error_port_allocation_threshold"></a> [natgateway\_error\_port\_allocation\_threshold](#input\_natgateway\_error\_port\_allocation\_threshold) | Threshold for NAT Gateway ErrorPortAllocation alarms. | `number` | `0` | no |
| <a name="input_natgateway_packets_drop_count_threshold"></a> [natgateway\_packets\_drop\_count\_threshold](#input\_natgateway\_packets\_drop\_count\_threshold) | Threshold for NAT Gateway PacketsDropCount alarms. | `number` | `100` | no |
| <a name="input_office_hours_buffer_minutes"></a> [office\_hours\_buffer\_minutes](#input\_office\_hours\_buffer\_minutes) | Buffer time in minutes before/after office hours to prevent startup/shutdown alarms. | `number` | `5` | no |
| <a name="input_project_tag_key"></a> [project\_tag\_key](#input\_project\_tag\_key) | Tag key used to identify project resources for alarm discovery. | `string` | `"lz:Service"` | no |
| <a name="input_project_tag_value"></a> [project\_tag\_value](#input\_project\_tag\_value) | Tag value used to identify project resources for alarm discovery. | `string` | `null` | no |
| <a name="input_rds_buffer_cache_hit_ratio_threshold"></a> [rds\_buffer\_cache\_hit\_ratio\_threshold](#input\_rds\_buffer\_cache\_hit\_ratio\_threshold) | Threshold for RDS BufferCacheHitRatio alarms. | `number` | `80` | no |
| <a name="input_rds_cpu_utilization_threshold"></a> [rds\_cpu\_utilization\_threshold](#input\_rds\_cpu\_utilization\_threshold) | Threshold for RDS CPUUtilization alarms. | `number` | `90` | no |
| <a name="input_rds_database_connections_threshold"></a> [rds\_database\_connections\_threshold](#input\_rds\_database\_connections\_threshold) | Threshold for RDS DatabaseConnections alarms. | `number` | `1000` | no |
| <a name="input_rds_db_load_threshold"></a> [rds\_db\_load\_threshold](#input\_rds\_db\_load\_threshold) | Threshold for RDS DBLoad alarms. | `number` | `4` | no |
| <a name="input_rds_freeable_memory_threshold"></a> [rds\_freeable\_memory\_threshold](#input\_rds\_freeable\_memory\_threshold) | Threshold for RDS FreeableMemory alarms. | `number` | `500000000` | no |
| <a name="input_rds_maximum_used_transaction_ids_threshold"></a> [rds\_maximum\_used\_transaction\_ids\_threshold](#input\_rds\_maximum\_used\_transaction\_ids\_threshold) | Threshold for RDS MaximumUsedTransactionIDs alarms. | `number` | `1000000000` | no |
| <a name="input_rds_read_latency_threshold"></a> [rds\_read\_latency\_threshold](#input\_rds\_read\_latency\_threshold) | Threshold for RDS ReadLatency alarms. | `number` | `20` | no |
| <a name="input_rds_storage_network_throughput_threshold"></a> [rds\_storage\_network\_throughput\_threshold](#input\_rds\_storage\_network\_throughput\_threshold) | Threshold for RDS StorageNetworkThroughput alarms. | `number` | `10000000` | no |
| <a name="input_rds_write_latency_threshold"></a> [rds\_write\_latency\_threshold](#input\_rds\_write\_latency\_threshold) | Threshold for RDS WriteLatency alarms. | `number` | `20` | no |
| <a name="input_sns_enable_anomaly_detection"></a> [sns\_enable\_anomaly\_detection](#input\_sns\_enable\_anomaly\_detection) | Enable anomaly detection for SNS delivery volume alarms. | `bool` | `false` | no |
| <a name="input_sns_messages_published_threshold"></a> [sns\_messages\_published\_threshold](#input\_sns\_messages\_published\_threshold) | Threshold for SNS NumberOfMessagesPublished alarms. | `number` | `1` | no |
| <a name="input_sns_notifications_failed_threshold"></a> [sns\_notifications\_failed\_threshold](#input\_sns\_notifications\_failed\_threshold) | Threshold for SNS NumberOfNotificationsFailed alarms. | `number` | `1` | no |
| <a name="input_sns_topic_alarm_config"></a> [sns\_topic\_alarm\_config](#input\_sns\_topic\_alarm\_config) | Per-SNS-topic delivery alarm configuration keyed by topic ARN. | <pre>map(object({<br/>    enabled        = bool<br/>    min_deliveries = number<br/>  }))</pre> | `{}` | no |
| <a name="input_sns_topic_arn"></a> [sns\_topic\_arn](#input\_sns\_topic\_arn) | SNS topic ARN used for all CloudWatch alarm actions. | `string` | `null` | no |
| <a name="input_sqs_age_of_oldest_message_threshold"></a> [sqs\_age\_of\_oldest\_message\_threshold](#input\_sqs\_age\_of\_oldest\_message\_threshold) | Threshold for SQS ApproximateAgeOfOldestMessage alarms in seconds. | `number` | `300` | no |
| <a name="input_sqs_messages_not_visible_threshold"></a> [sqs\_messages\_not\_visible\_threshold](#input\_sqs\_messages\_not\_visible\_threshold) | Threshold for SQS ApproximateNumberOfMessagesNotVisible alarms. | `number` | `10000` | no |
| <a name="input_sqs_messages_visible_threshold"></a> [sqs\_messages\_visible\_threshold](#input\_sqs\_messages\_visible\_threshold) | Threshold for SQS ApproximateNumberOfMessagesVisible alarms. | `number` | `5000` | no |
| <a name="input_sqs_number_of_messages_sent_threshold"></a> [sqs\_number\_of\_messages\_sent\_threshold](#input\_sqs\_number\_of\_messages\_sent\_threshold) | Threshold for SQS NumberOfMessagesSent alarms. | `number` | `0` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to all CloudWatch alarms created by the module. | `map(string)` | `{}` | no |
| <a name="input_waf_blocked_requests_threshold"></a> [waf\_blocked\_requests\_threshold](#input\_waf\_blocked\_requests\_threshold) | Threshold for WAFv2 BlockedRequests alarms. | `number` | `100` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_all_alarm_arns"></a> [all\_alarm\_arns](#output\_all\_alarm\_arns) | All CloudWatch alarms created by the module. |
<!-- END_TF_DOCS -->

## Usage
```hcl
module "alarms" {
  source = "git@github.com:ukhsa-collaboration/devops-terraform-standard-alarms.git"
}
```
