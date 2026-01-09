resource "aws_cloudwatch_metric_alarm" "days_to_expiry" {
  for_each = local.acm_certificates_regional

  # Intent            : "This alarm can proactively alert you about upcoming certificate expirations. It provides sufficient advance notice to allow for manual intervention, enabling you to renew or replace certificates before they expire. This helps you maintain the security and availability of TLS-enabled services. When this goes into ALARM, immediately investigate the certificate status and initiate the renewal process if necessary."
  # Threshold Justification : "The threshold provides a balance between early warning and avoiding false alarms. It allows sufficient time for manual intervention if automatic renewal fails. Adjust this value based on your certificate renewal process and operational response times."

  alarm_name                = format("cw-acm-%s-daystoexpiry", replace(lower(element(split("/", each.value.certificate_arn), length(split("/", each.value.certificate_arn)) - 1)), ":", "-"))
  alarm_description         = "Certificate nearing expiry; renew or re-import soon to avoid outages."
  actions_enabled           = true
  ok_actions                = local.ok_alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.insufficient_data_actions
  metric_name               = "DaysToExpiry"
  namespace                 = "AWS/CertificateManager"
  statistic                 = "Minimum"
  period                    = 86400
  dimensions = {
    CertificateArn = each.value.certificate_arn
  }
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  threshold           = var.certificate_days_to_expiry_threshold
  comparison_operator = "LessThanOrEqualToThreshold"
  treat_missing_data  = "breaching"
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "days_to_expiry_cdn" {
  for_each = local.acm_certificates

  # Intent            : "This alarm can proactively alert you about upcoming certificate expirations. It provides sufficient advance notice to allow for manual intervention, enabling you to renew or replace certificates before they expire. This helps you maintain the security and availability of TLS-enabled services. When this goes into ALARM, immediately investigate the certificate status and initiate the renewal process if necessary."
  # Threshold Justification : "The threshold provides a balance between early warning and avoiding false alarms. It allows sufficient time for manual intervention if automatic renewal fails. Adjust this value based on your certificate renewal process and operational response times."

  alarm_name                = format("cw-acm-%s-daystoexpiry", replace(lower(element(split("/", each.value.certificate_arn), length(split("/", each.value.certificate_arn)) - 1)), ":", "-"))
  alarm_description         = "Certificate nearing expiry; renew or re-import soon to avoid outages."
  actions_enabled           = true
  ok_actions                = local.ok_alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.insufficient_data_actions
  metric_name               = "DaysToExpiry"
  namespace                 = "AWS/CertificateManager"
  statistic                 = "Minimum"
  period                    = 86400
  dimensions = {
    CertificateArn = each.value.certificate_arn
  }
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  threshold           = var.certificate_days_to_expiry_threshold
  comparison_operator = "LessThanOrEqualToThreshold"
  treat_missing_data  = "breaching"
  region              = "us-east-1"
  tags                = var.tags
}
