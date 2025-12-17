resource "aws_cloudwatch_metric_alarm" "error_port_allocation" {
  for_each = local.nat_gateways

  # Intent            : "This alarm is used to detect if the NAT gateway could not allocate a source port."
  # Threshold Justification : "If the value of ErrorPortAllocation is greater than zero, that means too many concurrent connections to a single popular destination are open through NATGateway."

  alarm_name                = format("cw-natgateway-%s-errorportallocation", replace(lower(each.value.nat_gateway_id), "/", "-"))
  alarm_description         = "NAT Gateway cannot allocate ports; reduce connections or scale gateways."
  actions_enabled           = true
  ok_actions                = local.ok_alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  evaluation_periods        = 15
  datapoints_to_alarm       = 15
  threshold                 = var.natgateway_error_port_allocation_threshold
  comparison_operator       = "GreaterThanThreshold"
  treat_missing_data        = "notBreaching"

  dynamic "metric_query" {
    for_each = length(local.enabled_during_office_hours) > 0 ? [1] : []
    content {
      id          = "m2"
      expression  = local.office_hours_expression
      label       = "ErrorPortAllocationOfficeHours"
      return_data = true
    }
  }

  dynamic "metric_query" {
    for_each = length(local.enabled_during_office_hours) > 0 ? [1] : []
    content {
      id          = "m1"
      return_data = false

      metric {
        metric_name = "ErrorPortAllocation"
        namespace   = "AWS/NATGateway"
        period      = 60
        stat        = "Sum"

        dimensions = {
          NatGatewayId = each.value.nat_gateway_id
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
        metric_name = "ErrorPortAllocation"
        namespace   = "AWS/NATGateway"
        period      = 60
        stat        = "Sum"

        dimensions = {
          NatGatewayId = each.value.nat_gateway_id
        }
      }
    }
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "packets_drop_count" {
  for_each = local.nat_gateways


  # Intent            : "This alarm is used to detect if packets are being dropped by NAT Gateway."
  # Threshold Justification : "You should calculate the value of 0.01 percent of the total traffic on the NAT Gateway and use that result as the threshold value. Use historical data of the traffic on NAT Gateway to determine the threshold."

  alarm_name                = format("cw-natgateway-%s-packetsdropcount", replace(lower(each.value.nat_gateway_id), "/", "-"))
  alarm_description         = "Packets dropped by NAT Gateway; check service health and throughput."
  actions_enabled           = true
  ok_actions                = local.ok_alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions

  dynamic "metric_query" {
    for_each = length(local.enabled_during_office_hours) > 0 ? [1] : []
    content {
      id          = "m2"
      expression  = local.office_hours_expression
      label       = "PacketsDropCountOfficeHours"
      return_data = true
    }
  }

  dynamic "metric_query" {
    for_each = length(local.enabled_during_office_hours) > 0 ? [1] : []
    content {
      id          = "m1"
      return_data = false

      metric {
        metric_name = "PacketsDropCount"
        namespace   = "AWS/NATGateway"
        period      = 60
        stat        = "Sum"

        dimensions = {
          NatGatewayId = each.value.nat_gateway_id
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
        metric_name = "PacketsDropCount"
        namespace   = "AWS/NATGateway"
        period      = 60
        stat        = "Sum"

        dimensions = {
          NatGatewayId = each.value.nat_gateway_id
        }
      }
    }
  }

  evaluation_periods  = 5
  datapoints_to_alarm = 5
  threshold           = var.natgateway_packets_drop_count_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  tags                = var.tags
}
