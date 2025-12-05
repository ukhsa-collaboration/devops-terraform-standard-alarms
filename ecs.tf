resource "aws_cloudwatch_metric_alarm" "ecs_cpu" {
  for_each = local.ecs_services

  # Intent            : "This alarm is used to detect high CPU utilization for the ECS service. Consistent high CPU utilization can indicate a resource bottleneck or application performance problems."
  # Threshold Justification : "The service metrics for CPU utilization might exceed 100% utilization. However, we recommend that you monitor the metric for high CPU utilization to avoid impacting other services. Set the threshold to about 80%. We recommend that you update your task definitions to reflect actual usage to prevent future issues with other services."

  alarm_name                = format("cw-ecs-%s-cpuutilization", replace(lower(each.value.service_name), "/", "-"))
  alarm_description         = "ECS service CPU high; scale tasks or tune workload."
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/ECS"
  statistic                 = "Average"
  period                    = 60
  dimensions = {
    ServiceName = each.value.service_name
    ClusterName = each.value.cluster_name
  }
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  threshold           = var.ecs_cpu_utilization_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "breaching"
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory" {
  for_each = local.ecs_services

  # Intent            : "This alarm is used to detect high memory utilization for the ECS service. Consistent high memory utilization can indicate a resource bottleneck or application performance problems."
  # Threshold Justification : "The service metrics for memory utilization might exceed 100% utilization. However, we recommend that you monitor the metric for high memory utilization to avoid impacting other services. Set the threshold to about 80%. We recommend that you update your task definitions to reflect actual usage to prevent future issues with other services."

  alarm_name                = format("cw-ecs-%s-memoryutilization", replace(lower(each.value.service_name), "/", "-"))
  alarm_description         = "ECS service memory high; increase task memory or scale out."
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  metric_name               = "MemoryUtilization"
  namespace                 = "AWS/ECS"
  statistic                 = "Average"
  period                    = 60
  dimensions = {
    ServiceName = each.value.service_name
    ClusterName = each.value.cluster_name
  }
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  threshold           = var.ecs_memory_utilization_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "breaching"
  tags                = var.tags
}
