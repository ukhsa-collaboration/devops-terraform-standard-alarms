resource "aws_cloudwatch_metric_alarm" "waf_blocked_requests" {
  for_each = local.wafv2_web_acls

  alarm_name                = format("cw-waf-%s-blockedrequests", replace(lower(each.value.name), "/", "-"))
  alarm_description         = "Blocked requests spiking; review WAF rules and traffic."
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  metric_name               = "BlockedRequests"
  namespace                 = "AWS/WAFV2"
  statistic                 = "Sum"
  period                    = 300
  dimensions = {
    WebACL = each.value.name
    Region = each.value.region_dimension
  }
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  threshold           = var.waf_blocked_requests_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "missing"
  tags                = var.tags
}
