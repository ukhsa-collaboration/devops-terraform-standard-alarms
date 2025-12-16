data "aws_resourcegroupstaggingapi_resources" "ecs_services" {
  resource_type_filters = ["ecs:service"]

  tag_filter {
    key    = local.project_tag_key
    values = local.project_tag_values
  }
}

data "aws_resourcegroupstaggingapi_resources" "lambda_functions" {
  resource_type_filters = ["lambda:function"]

  tag_filter {
    key    = local.project_tag_key
    values = local.project_tag_values
  }
}

data "aws_resourcegroupstaggingapi_resources" "wafv2_web_acls" {
  resource_type_filters = [
    "wafv2:regional/webacl",
    "wafv2:global/webacl",
  ]

  tag_filter {
    key    = local.project_tag_key
    values = local.project_tag_values
  }
}

data "aws_resourcegroupstaggingapi_resources" "rds_instances" {
  resource_type_filters = ["rds:db"]

  tag_filter {
    key    = local.project_tag_key
    values = local.project_tag_values
  }
}

data "aws_resourcegroupstaggingapi_resources" "rds_clusters" {
  resource_type_filters = ["rds:cluster"]

  tag_filter {
    key    = local.project_tag_key
    values = local.project_tag_values
  }
}

data "aws_resourcegroupstaggingapi_resources" "elasticache_clusters" {
  resource_type_filters = ["elasticache:cluster"]

  tag_filter {
    key    = local.project_tag_key
    values = local.project_tag_values
  }
}

data "aws_resourcegroupstaggingapi_resources" "nat_gateways" {
  resource_type_filters = ["ec2:natgateway"]

  tag_filter {
    key    = local.project_tag_key
    values = local.project_tag_values
  }
}

data "aws_resourcegroupstaggingapi_resources" "sqs_queues" {
  resource_type_filters = ["sqs:queue"]

  tag_filter {
    key    = local.project_tag_key
    values = local.project_tag_values
  }
}

data "aws_resourcegroupstaggingapi_resources" "sns_topics" {
  resource_type_filters = ["sns:topic"]

  tag_filter {
    key    = local.project_tag_key
    values = local.project_tag_values
  }
}

data "aws_resourcegroupstaggingapi_resources" "cloudfront_distributions" {
  region                = "us-east-1"
  resource_type_filters = ["cloudfront:distribution"]

  tag_filter {
    key    = local.project_tag_key
    values = local.project_tag_values
  }
}

data "aws_resourcegroupstaggingapi_resources" "acm_certificates" {
  region                = "us-east-1"
  resource_type_filters = ["acm:certificate"]

  tag_filter {
    key    = local.project_tag_key
    values = local.project_tag_values
  }
}

data "aws_resourcegroupstaggingapi_resources" "acm_certificates_regional" {
  resource_type_filters = ["acm:certificate"]

  tag_filter {
    key    = local.project_tag_key
    values = local.project_tag_values
  }
}

data "aws_resourcegroupstaggingapi_resources" "application_load_balancers" {
  resource_type_filters = ["elasticloadbalancing:loadbalancer"]

  tag_filter {
    key    = local.project_tag_key
    values = local.project_tag_values
  }
}

data "aws_resourcegroupstaggingapi_resources" "application_load_balancer_target_groups" {
  resource_type_filters = ["elasticloadbalancing:targetgroup"]

  tag_filter {
    key    = local.project_tag_key
    values = local.project_tag_values
  }
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_elasticache_cluster" "discovered" {
  for_each = {
    for mapping in data.aws_resourcegroupstaggingapi_resources.elasticache_clusters.resource_tag_mapping_list :
    element(split(":", mapping.resource_arn), length(split(":", mapping.resource_arn)) - 1) => {
      arn = mapping.resource_arn
    }
  }

  cluster_id = replace(each.key, "cluster:", "")
}

locals {
  project_tag_key    = coalesce(var.project_tag_key, "lz:Service")
  project_tag_values = var.project_tag_value == null ? null : [var.project_tag_value]

  ecs_services = {
    for mapping in data.aws_resourcegroupstaggingapi_resources.ecs_services.resource_tag_mapping_list :
    mapping.resource_arn => {
      cluster_name = element(split("/", mapping.resource_arn), length(split("/", mapping.resource_arn)) - 2)
      service_name = element(split("/", mapping.resource_arn), length(split("/", mapping.resource_arn)) - 1)
    }
  }

  lambda_functions = {
    for mapping in data.aws_resourcegroupstaggingapi_resources.lambda_functions.resource_tag_mapping_list :
    mapping.resource_arn => {
      function_name = element(split(":", mapping.resource_arn), length(split(":", mapping.resource_arn)) - 1)
    }
    if try(mapping.tags["aws:cloudformation:logical-id"], "") != "CloudwatchAlarmNotificationLambda"
  }

  cloudfront_distributions = {
    for mapping in data.aws_resourcegroupstaggingapi_resources.cloudfront_distributions.resource_tag_mapping_list :
    mapping.resource_arn => {
      distribution_id = element(split("/", mapping.resource_arn), length(split("/", mapping.resource_arn)) - 1)
    }
  }

  wafv2_web_acls = {
    for mapping in data.aws_resourcegroupstaggingapi_resources.wafv2_web_acls.resource_tag_mapping_list :
    mapping.resource_arn => {
      name             = element(split("/", mapping.resource_arn), length(split("/", mapping.resource_arn)) - 2)
      scope            = element(split(":", mapping.resource_arn), 3)
      region_dimension = element(split(":", mapping.resource_arn), 3) == "global" ? "Global" : element(split(":", mapping.resource_arn), 3)
    }
  }

  rds_instances = {
    for mapping in data.aws_resourcegroupstaggingapi_resources.rds_instances.resource_tag_mapping_list :
    mapping.resource_arn => {
      identifier = element(split(":", mapping.resource_arn), length(split(":", mapping.resource_arn)) - 1)
    }
  }

  rds_clusters = {
    for mapping in data.aws_resourcegroupstaggingapi_resources.rds_clusters.resource_tag_mapping_list :
    mapping.resource_arn => {
      identifier = element(split(":", mapping.resource_arn), length(split(":", mapping.resource_arn)) - 1)
    }
  }

  elasticache_clusters = {
    for id, cluster in data.aws_elasticache_cluster.discovered :
    id => {
      cluster_id = cluster.id
      node_ids   = cluster.cache_nodes[*].id
    }
  }

  nat_gateways = {
    for mapping in data.aws_resourcegroupstaggingapi_resources.nat_gateways.resource_tag_mapping_list :
    mapping.resource_arn => {
      nat_gateway_id = element(split("/", mapping.resource_arn), length(split("/", mapping.resource_arn)) - 1)
    }
  }

  sqs_queues = {
    for mapping in data.aws_resourcegroupstaggingapi_resources.sqs_queues.resource_tag_mapping_list :
    mapping.resource_arn => {
      queue_name = element(split(":", mapping.resource_arn), length(split(":", mapping.resource_arn)) - 1)
    }
  }

  sns_topics = {
    for mapping in data.aws_resourcegroupstaggingapi_resources.sns_topics.resource_tag_mapping_list :
    mapping.resource_arn => {
      topic_name = element(split(":", mapping.resource_arn), length(split(":", mapping.resource_arn)) - 1)
    }
    if mapping.resource_arn != local.sns_topic_arn
  }

  acm_certificates = {
    for mapping in data.aws_resourcegroupstaggingapi_resources.acm_certificates.resource_tag_mapping_list :
    mapping.resource_arn => {
      certificate_arn = mapping.resource_arn
    }
  }

  acm_certificates_regional = {
    for mapping in data.aws_resourcegroupstaggingapi_resources.acm_certificates_regional.resource_tag_mapping_list :
    mapping.resource_arn => {
      certificate_arn = mapping.resource_arn
    }
  }

  application_load_balancers = {
    for mapping in data.aws_resourcegroupstaggingapi_resources.application_load_balancers.resource_tag_mapping_list :
    mapping.resource_arn => {
      load_balancer_dimension = element(split("loadbalancer/", mapping.resource_arn), 1)
      load_balancer_name      = replace(lower(element(split("loadbalancer/", mapping.resource_arn), 1)), "/", "-")
    }
  }

  application_load_balancer_target_groups = {
    for mapping in data.aws_resourcegroupstaggingapi_resources.application_load_balancer_target_groups.resource_tag_mapping_list :
    mapping.resource_arn => {
      target_group_dimension = format("targetgroup/%s", element(split("targetgroup/", mapping.resource_arn), 1))
      target_group_name      = replace(lower(format("targetgroup/%s", element(split("targetgroup/", mapping.resource_arn), 1))), "/", "-")
    }
  }

  sns_topic_arn = coalesce(
    var.sns_topic_arn,
    format(
      "arn:aws:sns:%s:%s:aw-phe-%s-sns-cloudwatch_alarms",
      data.aws_region.current.region,
      data.aws_caller_identity.current.account_id,
      data.aws_region.current.region
    )
  )

  alarm_actions = compact([local.sns_topic_arn])

  enabled_during_office_hours = var.alarm_schedule == "OfficeHours" ? ["OfficeHours"] : []

  # Office hours configuration constants
  office_hours_start_hour = 9  # 09:00 UTC
  office_hours_end_hour   = 17 # 17:00 UTC (5:00 PM)

  # Buffer time calculations with minute-level precision
  office_hours_buffer_hours = floor(var.office_hours_buffer_minutes / 60)
  office_hours_buffer_mins  = var.office_hours_buffer_minutes % 60

  # Calculate effective start time with buffer (e.g., 09:05 UTC with 5-minute buffer)
  effective_start_hour = local.office_hours_start_hour + local.office_hours_buffer_hours
  effective_start_min  = local.office_hours_buffer_mins

  # Calculate effective end time with buffer (e.g., 16:55 UTC with 5-minute buffer)
  # Handle case where buffer minutes cause hour rollback
  effective_end_hour = local.office_hours_end_hour - local.office_hours_buffer_hours - (local.office_hours_buffer_mins > 0 ? 1 : 0)
  effective_end_min  = local.office_hours_buffer_mins > 0 ? 60 - local.office_hours_buffer_mins : 0

  # Primary office hours expression - simplified to use hour-only logic for CloudWatch compatibility
  # Monday=1, Tuesday=2, ..., Friday=5, Saturday=6, Sunday=7
  # Active during: Monday-Friday, with buffer time applied at hour boundaries
  # Note: Buffer time is applied by adjusting the effective hours (e.g., 09:00-17:00 becomes 10:00-16:00 with 1-hour buffer)
  office_hours_expression = "IF((DAY(m1)>=1 AND DAY(m1)<=5 AND HOUR(m1)>=${local.office_hours_start_hour + ceil(var.office_hours_buffer_minutes / 60.0)} AND HOUR(m1)<${local.office_hours_end_hour - ceil(var.office_hours_buffer_minutes / 60.0)}),m1)"

  # Simplified hour-only expression for cases where minute precision isn't critical
  # Uses hour boundaries only, applying buffer at hour level
  office_hours_expression_simple = "IF((DAY(m1)>=1 AND DAY(m1)<=5 AND HOUR(m1)>=${local.effective_start_hour} AND HOUR(m1)<=${local.effective_end_hour}),m1)"

  # Helper expressions for different office hours scenarios

  # Weekdays only (no time restriction) - useful for daily batch jobs
  office_hours_weekdays_only = "IF((DAY(m1)>=1 AND DAY(m1)<=5),m1)"

  # Business hours only (no day restriction) - useful for time-sensitive operations
  office_hours_business_hours_only = "IF((HOUR(m1)>=${local.office_hours_start_hour} AND HOUR(m1)<${local.office_hours_end_hour}),m1)"

  # Standard office hours without buffer - exact 09:00-17:00 Monday-Friday
  office_hours_no_buffer = "IF((DAY(m1)>=1 AND DAY(m1)<=5 AND HOUR(m1)>=${local.office_hours_start_hour} AND HOUR(m1)<${local.office_hours_end_hour}),m1)"

  # Extended office hours (07:00-19:00) - for services that need wider monitoring
  office_hours_extended = "IF((DAY(m1)>=1 AND DAY(m1)<=5 AND HOUR(m1)>=7 AND HOUR(m1)<19),m1)"

  # 24x7 expression (always returns data) - for continuous monitoring
  always_active_expression = "m1"

  # Missing Data Treatment Standards
  # 
  # This module applies standardized missing data treatment based on alarm type:
  #
  # 1. UTILIZATION METRICS (treat_missing_data = "missing"):
  #    - CPU utilization, memory utilization, database connections, freeable memory
  #    - Rationale: Missing utilization data typically indicates the resource is not active
  #      or not generating metrics. Treating as "missing" prevents false alarms during
  #      legitimate downtime or when resources are scaled to zero.
  #    - Examples: ECS CPU/Memory, RDS CPU/Memory/Connections, ElastiCache CPU/Memory
  #
  # 2. ERROR/FAILURE METRICS (treat_missing_data = "notBreaching"):
  #    - Error counts, failure rates, latency metrics, throttling
  #    - Rationale: Missing error data usually means no errors are occurring, which is
  #      the desired state. Treating as "notBreaching" prevents alarms during periods
  #      of no activity while still alerting on actual error conditions.
  #    - Examples: ALB 5xx errors, Lambda errors/throttles, WAF blocked requests,
  #      NAT Gateway errors, SQS message processing issues, SNS delivery failures
  #
  # 3. AVAILABILITY/UPTIME METRICS (treat_missing_data = "breaching"):
  #    - Uptime indicators, certificate expiry, connectivity checks
  #    - Rationale: Missing availability data often indicates a problem with the service
  #      itself. Treating as "breaching" ensures alerts are triggered when monitoring
  #      data stops flowing, which may indicate service outages.
  #    - Examples: RDS engine uptime, ACM certificate expiry monitoring
  #
  # This standardization ensures consistent alarm behavior across all AWS services
  # and reduces false positives while maintaining appropriate alerting sensitivity.
}
