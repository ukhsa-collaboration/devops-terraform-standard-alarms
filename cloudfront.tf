# TODO: Create a relay Lambda inside of us-east-1 so that these alarms can be forwarded.

resource "aws_cloudwatch_metric_alarm" "cloudfront_5xx_error_rate" {
  for_each = local.cloudfront_distributions

  # Intent            : "This alarm is used to detect problems with serving requests from the origin server, or problems with communication between CloudFront and your origin server."
  # Threshold Justification : "The recommended threshold value for this alarm is highly dependent on the tolerance for 5xx responses. You can analyze historical data and trends, and then set the threshold accordingly. Because 5xx errors can be caused by transient issues, we recommend that you set the threshold to a value greater than 0 so that the alarm is not too sensitive."

  alarm_name        = format("cw-cloudfront-%s-5xxerrorrate", lower(each.value.distribution_id))
  alarm_description = "CloudFront 5xx rate high; check origin health and errors."
  actions_enabled   = true
  # ok_actions                = local.alarm_actions
  # alarm_actions             = local.alarm_actions
  # insufficient_data_actions = local.alarm_actions
  metric_name = "5xxErrorRate"
  namespace   = "AWS/CloudFront"
  statistic   = "Average"
  period      = 60
  dimensions = {
    Region         = "Global"
    DistributionId = each.value.distribution_id
  }
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  threshold           = var.cloudfront_5xx_error_rate_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  tags                = var.tags
  region              = "us-east-1"
}

resource "aws_cloudwatch_metric_alarm" "cloudfront_origin_latency" {
  for_each = local.cloudfront_distributions

  # Intent            : "This alarm is used to detect problems with the origin server taking too long to respond."
  # Threshold Justification : "You should calculate the value of about 80% of the origin response timeout, and use the result as the threshold value. If this metric is consistently close to the origin response timeout value, you might start experiencing 504 errors."

  alarm_name        = format("cw-cloudfront-%s-originlatency", lower(each.value.distribution_id))
  alarm_description = "Origin latency high; investigate origin response times/timeouts."
  actions_enabled   = true
  # ok_actions                = local.alarm_actions
  # alarm_actions             = local.alarm_actions
  # insufficient_data_actions = local.alarm_actions
  metric_name        = "OriginLatency"
  namespace          = "AWS/CloudFront"
  extended_statistic = "p90"
  period             = 60
  dimensions = {
    Region         = "Global"
    DistributionId = each.value.distribution_id
  }
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  threshold           = var.cloudfront_origin_latency_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  tags                = var.tags
  region              = "us-east-1"
}
