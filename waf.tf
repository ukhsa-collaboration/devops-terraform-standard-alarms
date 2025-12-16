resource "aws_cloudwatch_metric_alarm" "waf_blocked_requests" {
  for_each = local.wafv2_web_acls

  alarm_name                = format("cw-waf-%s-blockedrequests", replace(lower(each.value.name), "/", "-"))
  alarm_description         = "Blocked requests spiking; review WAF rules and traffic."
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  evaluation_periods        = 1
  datapoints_to_alarm       = 1
  threshold                 = var.waf_blocked_requests_threshold
  comparison_operator       = "GreaterThanThreshold"
  treat_missing_data        = "notBreaching"

  dynamic "metric_query" {
    for_each = length(local.enabled_during_office_hours) > 0 ? [1] : []
    content {
      id          = "m2"
      expression  = local.office_hours_expression
      label       = "BlockedRequestsOfficeHours"
      return_data = true
    }
  }

  dynamic "metric_query" {
    for_each = length(local.enabled_during_office_hours) > 0 ? [1] : []
    content {
      id          = "m1"
      return_data = false

      metric {
        metric_name = "BlockedRequests"
        namespace   = "AWS/WAFV2"
        period      = 300
        stat        = "Sum"

        dimensions = {
          WebACL = each.value.name
          Region = each.value.region_dimension
        }
      }
    }
  }

  dynamic "metric_query" {
    for_each = length(local.enabled_during_office_hours) == 0 ? [1] : []
    content {
      id          = "m1"
      return_data = true

      metric {
        metric_name = "BlockedRequests"
        namespace   = "AWS/WAFV2"
        period      = 300
        stat        = "Sum"

        dimensions = {
          WebACL = each.value.name
          Region = each.value.region_dimension
        }
      }
    }
  }
  tags = var.tags
}
