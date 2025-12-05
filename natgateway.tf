resource "aws_cloudwatch_metric_alarm" "error_port_allocation" {
  for_each = local.nat_gateways

  # Intent            : "This alarm is used to detect if the NAT gateway could not allocate a source port."
  # Threshold Justification : "If the value of ErrorPortAllocation is greater than zero, that means too many concurrent connections to a single popular destination are open through NATGateway."

  alarm_name                = format("cw-natgateway-%s-errorportallocation", replace(lower(each.value.nat_gateway_id), "/", "-"))
  alarm_description         = "NAT Gateway cannot allocate ports; reduce connections or scale gateways."
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  metric_name               = "ErrorPortAllocation"
  namespace                 = "AWS/NATGateway"
  statistic                 = "Sum"
  period                    = 60
  dimensions = {
    NatGatewayId = each.value.nat_gateway_id
  }
  evaluation_periods  = 15
  datapoints_to_alarm = 15
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "missing"
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "packets_drop_count" {
  for_each = local.nat_gateways


  # Intent            : "This alarm is used to detect if packets are being dropped by NAT Gateway."
  # Threshold Justification : "You should calculate the value of 0.01 percent of the total traffic on the NAT Gateway and use that result as the threshold value. Use historical data of the traffic on NAT Gateway to determine the threshold."

  alarm_name                = format("cw-natgateway-%s-packetsdropcount", replace(lower(each.value.nat_gateway_id), "/", "-"))
  alarm_description         = "Packets dropped by NAT Gateway; check service health and throughput."
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  metric_name               = "PacketsDropCount"
  namespace                 = "AWS/NATGateway"
  statistic                 = "Sum"
  period                    = 60
  dimensions = {
    NatGatewayId = each.value.nat_gateway_id
  }
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  threshold           = 100
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "missing"
  tags                = var.tags
}
