locals {
  sns_delivery_alarm_topics = var.enable_sns_volume_alarms ? { for k, v in local.sns_topics : k => v if try(var.sns_topic_alarm_config[k].enabled, false) } : {}
}

resource "aws_cloudwatch_metric_alarm" "number_of_messages_published" {
  for_each = local.sns_topics

  # Intent            : "This alarm helps you proactively monitor and detect significant drops in notification publishing. This helps you identify potential issues with your application or business processes, so that you can take appropriate actions to maintain the expected flow of notifications. You should create this alarm if you expect your system to have a minimum traffic that it is serving."
  # Threshold Justification : "The number of messages published should be in line with the expected number of published messages for your application. You can also analyze the historical data, trends and traffic to find the right threshold."

  alarm_name                = format("cw-sns-%s-numberofmessagespublished", replace(lower(each.value.topic_name), "/", "-"))
  alarm_description         = "SNS publishes dropped; check publishers and upstream traffic."
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  metric_name               = "NumberOfMessagesPublished"
  namespace                 = "AWS/SNS"
  statistic                 = "Sum"
  period                    = 60
  dimensions = {
    TopicName = each.value.topic_name
  }
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  threshold           = 1
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "breaching"
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "number_of_notifications_delivered" {
  for_each = var.sns_enable_anomaly_detection ? {} : local.sns_delivery_alarm_topics

  # Intent            : "This alarm helps you detect a drop in the volume of messages delivered. You should create this alarm if you expect your system to have a minimum traffic that it is serving."
  # Threshold Justification : "The number of messages delivered should be in line with the expected number of messages produced and the number of consumers. You can also analyze the historical data, trends and traffic to find the right threshold."

  alarm_name                = format("cw-sns-%s-numberofnotificationsdelivered", replace(lower(each.value.topic_name), "/", "-"))
  alarm_description         = "SNS deliveries low; check subscriber health and recent unsubscribes."
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  metric_name               = "NumberOfNotificationsDelivered"
  namespace                 = "AWS/SNS"
  statistic                 = "Sum"
  period                    = 60
  dimensions = {
    TopicName = each.value.topic_name
  }
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  threshold           = lookup(var.sns_topic_alarm_config[each.key], "min_deliveries", 1)
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "notBreaching"
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "number_of_notifications_delivered_anomaly" {
  for_each = var.sns_enable_anomaly_detection ? local.sns_delivery_alarm_topics : {}

  # Intent            : "This alarm helps you detect a drop in the volume of messages delivered. You should create this alarm if you expect your system to have a minimum traffic that it is serving."
  # Threshold Justification : "The number of messages delivered should be in line with the expected number of messages produced and the number of consumers. You can also analyze the historical data, trends and traffic to find the right threshold."

  alarm_name                = format("cw-sns-%s-numberofnotificationsdelivered", replace(lower(each.value.topic_name), "/", "-"))
  alarm_description         = "SNS deliveries low; check subscriber health and recent unsubscribes."
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  comparison_operator       = "LessThanLowerThreshold"
  evaluation_periods        = 5
  datapoints_to_alarm       = 5
  treat_missing_data        = "notBreaching"
  tags                      = var.tags

  metric_query {
    id          = "m1"
    return_data = true
    metric {
      metric_name = "NumberOfNotificationsDelivered"
      namespace   = "AWS/SNS"
      period      = 60
      stat        = "Sum"
      dimensions = {
        TopicName = each.value.topic_name
      }
    }
  }

  metric_query {
    id          = "ad1"
    expression  = "ANOMALY_DETECTION_BAND(m1, 2)"
    return_data = true
  }

  threshold_metric_id = "ad1"
}

resource "aws_cloudwatch_metric_alarm" "number_of_notifications_failed" {
  for_each = local.sns_topics

  # Intent            : "This alarm helps you detect a spike in the volume of notification delivery failures or errors. This can be an indication of problems with your application or issues with the notification endpoints. This helps you detect and remediate issues quickly to ensure high availability of the notification delivery process."
  # Threshold Justification : "The threshold for failed notifications depends on the number of endpoints and the expected rate of notifications for your application. You can use historical data for the number of errors to set the threshold."

  alarm_name                = format("cw-sns-%s-numberofnotificationsfailed", replace(lower(each.value.topic_name), "/", "-"))
  alarm_description         = "SNS notification failures spiking; inspect endpoint health and retry logic."
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  metric_name               = "NumberOfNotificationsFailed"
  namespace                 = "AWS/SNS"
  statistic                 = "Sum"
  period                    = 60
  dimensions = {
    TopicName = each.value.topic_name
  }
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  threshold           = 1
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "breaching"
  tags                = var.tags
}
