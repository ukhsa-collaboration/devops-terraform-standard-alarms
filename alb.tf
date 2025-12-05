resource "aws_cloudwatch_metric_alarm" "alb_target_5xx" {
  for_each = local.application_load_balancers

  # Intent            : "This alarm is used to detect a rise in 5XX responses returned by ALB targets. Persistent 5XX errors often indicate backend outages, misconfigurations, or dependency failures that should be remediated quickly."
  # Threshold Justification : "The recommended threshold value depends on normal traffic and error tolerance. Alerting at 5 target 5XX responses over a 5-minute window helps surface sustained failures while avoiding noise from isolated blips."

  alarm_name                = format("cw-alb-%s-target-5xx", each.value.load_balancer_name)
  alarm_description         = "Application Load Balancer is returning 5XX responses"
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  metric_name               = "HTTPCode_Target_5XX_Count"
  namespace                 = "AWS/ApplicationELB"
  statistic                 = "Sum"
  period                    = 300
  dimensions = {
    LoadBalancer = each.value.load_balancer_dimension
  }
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  threshold           = var.alb_target_5xx_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "alb_target_response_time" {
  for_each = local.application_load_balancer_target_groups

  # Intent            : "This alarm is used to detect elevated end-to-end response time from ALB targets. Consistently slow targets can signal backend performance issues, exhausted capacity, or dependency latency that needs investigation."
  # Threshold Justification : "The recommended threshold value depends on application SLOs and typical latency. Alerting when average target latency exceeds 750 ms for several minutes balances sensitivity to sustained slowness while avoiding noise from transient single slow requests."

  alarm_name                = format("cw-alb-%s-targetresponsetime", each.value.target_group_name)
  alarm_description         = "Application Load Balancer target response time is elevated"
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  metric_name               = "TargetResponseTime"
  namespace                 = "AWS/ApplicationELB"
  statistic                 = "Average"
  period                    = 60
  dimensions = {
    TargetGroup = each.value.target_group_dimension
  }
  evaluation_periods  = 3
  datapoints_to_alarm = 3
  threshold           = var.alb_target_response_time_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  tags                = var.tags
}
