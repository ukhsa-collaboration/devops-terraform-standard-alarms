resource "aws_cloudwatch_metric_alarm" "lambda_claimed_account_concurrency" {
  count = length(local.lambda_functions) > 0 ? 1 : 0

  # Intent            : "This alarm can proactively detect if the concurrency of your Lambda functions is approaching the Region-level concurrency quota of your account, so that you can act on it. Functions are throttled if ClaimedAccountConcurrency reaches the Region-level concurrency quota of the account. If you are using Reserved Concurrency (RC) or Provisioned Concurrency (PC), this alarm gives you more visibility on concurrency utilization than an alarm on ConcurrentExecutions would."
  # Threshold Justification : "You should calculate the value of about 90% of the concurrency quota set for the account in the Region, and use the result as the threshold value. By default, your account has a concurrency quota of 1,000 across all functions in a Region. However, you should check the quota of your account from the Service Quotas dashboard."

  alarm_name                = "cw-lambda-account-claimedaccountconcurrency"
  alarm_description         = "Account concurrency near limit; request increase or reduce RC/PC usage."
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  metric_name               = "ClaimedAccountConcurrency"
  namespace                 = "AWS/Lambda"
  statistic                 = "Maximum"
  period                    = 60
  dimensions                = {}
  evaluation_periods        = 10
  datapoints_to_alarm       = 10
  threshold                 = var.lambda_claimed_account_concurrency_threshold
  comparison_operator       = "GreaterThanThreshold"
  treat_missing_data        = "notBreaching"
  tags                      = var.tags
}

resource "aws_cloudwatch_metric_alarm" "lambda_concurrent_executions" {
  for_each = local.lambda_functions

  # Intent            : "This alarm can proactively detect if the concurrency of the function is approaching the Region-level concurrency quota of your account, so that you can act on it. A function is throttled if it reaches the Region-level concurrency quota of the account."
  # Threshold Justification : "Set the threshold to about 90% of the concurrency quota set for the account in the Region. By default, your account has a concurrency quota of 1,000 across all functions in a Region. However, you can check the quota of your account, as it can be increased by contacting AWS support."

  alarm_name                = format("cw-lambda-%s-concurrentexecutions", replace(lower(each.value.function_name), "/", "-"))
  alarm_description         = "Function concurrency near account limit; optimize or request increase."
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  metric_name               = "ConcurrentExecutions"
  namespace                 = "AWS/Lambda"
  statistic                 = "Maximum"
  period                    = 60
  dimensions = {
    FunctionName = each.value.function_name
  }
  evaluation_periods  = 10
  datapoints_to_alarm = 10
  threshold           = var.lambda_concurrent_executions_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "missing"
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  for_each = local.lambda_functions

  # Intent            : "This alarm can detect a long running duration of a Lambda function. High runtime duration indicates that a function is taking a longer time for invocation, and can also impact the concurrency capacity of invocation if Lambda is handling a higher number of events. It is critical to know if the Lambda function is constantly taking longer execution time than expected."
  # Threshold Justification : "The threshold for the duration depends on your application and workloads and your performance requirements. For high-performance requirements, set the threshold to a shorter time to see if the function is meeting expectations. You can also analyze historical data for duration metrics to see the if the time taken matches the performance expectation of the function, and then set the threshold to a longer time than the historical average. Make sure to set the threshold lower than the configured function timeout."

  alarm_name                = format("cw-lambda-%s-duration", replace(lower(each.value.function_name), "/", "-"))
  alarm_description         = "Function duration high; review code, dependencies, and timeout."
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  metric_name               = "Duration"
  namespace                 = "AWS/Lambda"
  extended_statistic        = "p90"
  period                    = 60
  dimensions = {
    FunctionName = each.value.function_name
  }
  evaluation_periods  = 15
  datapoints_to_alarm = 15
  threshold           = var.lambda_duration_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "missing"
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  for_each = local.lambda_functions

  # Intent            : "The alarm helps detect high error counts in function invocations."
  # Threshold Justification : "Set the threshold to a number greater than zero. The exact value can depend on the tolerance for errors in your application. Understand the criticality of the invocations that the function is handling. For some applications, any error might be unacceptable, while other applications might allow for a certain margin of error."

  alarm_name                = format("cw-lambda-%s-errors", replace(lower(each.value.function_name), "/", "-"))
  alarm_description         = "Function errors elevated; inspect logs and recent changes."
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  metric_name               = "Errors"
  namespace                 = "AWS/Lambda"
  statistic                 = "Sum"
  period                    = 60
  dimensions = {
    FunctionName = each.value.function_name
  }
  evaluation_periods  = 3
  datapoints_to_alarm = 3
  threshold           = var.lambda_errors_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "missing"
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  for_each = local.lambda_functions

  # Intent            : "The alarm helps detect a high number of throttled invocation requests for a Lambda function. It is important to know if requests are constantly getting rejected due to throttling and if you need to improve Lambda function performance or increase concurrency capacity to avoid constant throttling."
  # Threshold Justification : "Set the threshold to a number greater than zero. The exact value of the threshold can depend on the tolerance of the application. Set the threshold according to its usage and scaling requirements of the function."

  alarm_name                = format("cw-lambda-%s-throttles", replace(lower(each.value.function_name), "/", "-"))
  alarm_description         = "Function throttling; increase concurrency or reduce load."
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  metric_name               = "Throttles"
  namespace                 = "AWS/Lambda"
  statistic                 = "Sum"
  period                    = 60
  dimensions = {
    FunctionName = each.value.function_name
  }
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  threshold           = var.lambda_throttles_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "missing"
  tags                = var.tags
}
