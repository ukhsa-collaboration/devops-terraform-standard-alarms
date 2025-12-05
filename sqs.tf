resource "aws_cloudwatch_metric_alarm" "approximate_age_of_oldest_message" {
  for_each = local.sqs_queues

  # Intent            : "This alarm is used to detect whether the age of the oldest message in the QueueName queue is too high. High age can be an indication that messages are not processed quickly enough or that there are some poison-pill messages that are stuck in the queue and can't be processed. "
  # Threshold Justification : "The recommended threshold value for this alarm is highly dependent on the expected message processing time. You can use historical data to calculate the average message processing time, and then set the threshold to 50% higher than the maximum expected SQS message processing time by queue consumers."

  alarm_name                = format("cw-sqs-%s-approximateageofoldestmessage", replace(lower(each.value.queue_name), "/", "-"))
  alarm_description         = "Oldest message age high; add or speed up consumers and check DLQ for poison pills."
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  metric_name               = "ApproximateAgeOfOldestMessage"
  namespace                 = "AWS/SQS"
  statistic                 = "Maximum"
  period                    = 60
  dimensions = {
    QueueName = each.value.queue_name
  }
  evaluation_periods  = 15
  datapoints_to_alarm = 15
  threshold           = var.sqs_age_of_oldest_message_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "missing"
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "approximate_number_of_messages_not_visible" {
  for_each = local.sqs_queues

  # Intent            : "This alarm is used to detect a high number of in-flight messages in the queue. If consumers do not delete messages within the visibility timeout period, when the queue is polled, messages reappear in the queue. For FIFO queues, there can be a maximum of 20,000 in-flight messages. If you reach this quota, SQS returns no error messages. A FIFO queue looks through the first 20k messages to determine available message groups. This means that if you have a backlog of messages in a single message group, you cannot consume messages from other message groups that were sent to the queue at a later time until you successfully consume the messages from the backlog."
  # Threshold Justification : "The recommended threshold value for this alarm is highly dependent on the expected number of messages in flight. You can use historical data to calculate the maximum expected number of messages in flight and set the threshold to 50% over this value. If consumers of the queue are processing but not deleting messages from the queue, this number will suddenly increase."

  alarm_name                = format("cw-sqs-%s-approximatenumberofmessagesnotvisible", replace(lower(each.value.queue_name), "/", "-"))
  alarm_description         = "In-flight messages high; ensure consumers delete messages within visibility timeout."
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  metric_name               = "ApproximateNumberOfMessagesNotVisible"
  namespace                 = "AWS/SQS"
  statistic                 = "Average"
  period                    = 60
  dimensions = {
    QueueName = each.value.queue_name
  }
  evaluation_periods  = 15
  datapoints_to_alarm = 15
  threshold           = var.sqs_messages_not_visible_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "missing"
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "approximate_number_of_messages_visible" {
  for_each = local.sqs_queues


  # Intent            : "This alarm is used to detect whether the message count of the active queue is too high and consumers are slow to process the messages or there are not enough consumers to process them."
  # Threshold Justification : "An unexpectedly high number of messages visible indicates that messages are not being processed by a consumer at the expected rate. You should consider historical data when you set this threshold."

  alarm_name                = format("cw-sqs-%s-approximatenumberofmessagesvisible", replace(lower(each.value.queue_name), "/", "-"))
  alarm_description         = "Queue backlog growing; add/scale consumers or investigate processing speed."
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  metric_name               = "ApproximateNumberOfMessagesVisible"
  namespace                 = "AWS/SQS"
  statistic                 = "Average"
  period                    = 60
  dimensions = {
    QueueName = each.value.queue_name
  }
  evaluation_periods  = 15
  datapoints_to_alarm = 15
  threshold           = var.sqs_messages_visible_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "missing"
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "number_of_messages_sent" {
  for_each = local.sqs_queues

  # Intent            : "This alarm is used to detect when a producer stops sending messages."
  # Threshold Justification : "If the number of messages sent is 0, the producer is not sending any messages. If this queue has a low TPS, increase the number of EvaluationPeriods accordingly. "

  alarm_name                = format("cw-sqs-%s-numberofmessagessent", replace(lower(each.value.queue_name), "/", "-"))
  alarm_description         = "No messages sent to queue; check producers for failures or traffic drops."
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  metric_name               = "NumberOfMessagesSent"
  namespace                 = "AWS/SQS"
  statistic                 = "Sum"
  period                    = 60
  dimensions = {
    QueueName = each.value.queue_name
  }
  evaluation_periods  = 15
  datapoints_to_alarm = 15
  threshold           = var.sqs_number_of_messages_sent_threshold
  comparison_operator = "LessThanOrEqualToThreshold"
  treat_missing_data  = "missing"
  tags                = var.tags
}
