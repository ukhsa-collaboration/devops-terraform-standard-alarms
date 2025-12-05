resource "aws_cloudwatch_metric_alarm" "rds_buffer_cache_hit_ratio" {
  for_each = local.rds_instances

  # Intent            : "This alarm is used to detect consistent low cache hit ratio in order to prevent a sustained performance decrease in the Aurora instance."
  # Threshold Justification : "You can set the threshold for buffer cache hit ratio to 80%. However, you can adjust this value based on your acceptable performance level and workload characteristics."

  alarm_name                = format("cw-rds-%s-buffercachehitratio", replace(lower(each.value.identifier), "/", "-"))
  alarm_description         = "Buffer cache hit ratio low; investigate queries and memory sizing."
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  metric_name               = "BufferCacheHitRatio"
  namespace                 = "AWS/RDS"
  statistic                 = "Average"
  period                    = 60
  dimensions = {
    DBInstanceIdentifier = each.value.identifier
  }
  evaluation_periods  = 10
  datapoints_to_alarm = 10
  threshold           = var.rds_buffer_cache_hit_ratio_threshold
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "missing"
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu_utilization" {
  for_each = local.rds_instances

  # Intent            : "This alarm is used to detect consistent high CPU utilization in order to prevent very high response time and time-outs. If you want to check micro-bursting of CPU utilization you can set a lower alarm evaluation time."
  # Threshold Justification : "Random spikes in CPU consumption may not hamper database performance, but sustained high CPU can hinder upcoming database requests. Depending on the overall database workload, high CPU at your RDS/Aurora instance can degrade the overall performance."

  alarm_name                = format("cw-rds-%s-cpuutilization", replace(lower(each.value.identifier), "/", "-"))
  alarm_description         = "DB CPU high; tune queries or scale instance class."
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/RDS"
  statistic                 = "Average"
  period                    = 60
  dimensions = {
    DBInstanceIdentifier = each.value.identifier
  }
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  threshold           = var.rds_cpu_utilization_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "breaching"
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "rds_database_connections" {
  for_each = local.rds_instances

  # Intent            : "This alarm is used to help prevent rejected connections when the maximum number of DB connections is reached. This alarm is not recommended if you frequently change DB instance class, because doing so changes the memory and default maximum number of connections."
  # Threshold Justification : "The number of connections allowed depends on the size of your DB instance class and database engine-specific parameters related to processes/connections. You should calculate a value between 90-95% of the maximum number of connections for your database and use that result as the threshold value."

  alarm_name                = format("cw-rds-%s-databaseconnections", replace(lower(each.value.identifier), "/", "-"))
  alarm_description         = "DB connections near limit; pool or scale instance."
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  metric_name               = "DatabaseConnections"
  namespace                 = "AWS/RDS"
  statistic                 = "Average"
  period                    = 60
  dimensions = {
    DBInstanceIdentifier = each.value.identifier
  }
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  threshold           = var.rds_database_connections_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "breaching"
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "rds_db_load" {
  for_each = local.rds_instances

  # Intent            : "This alarm is used to detect a high DB load. High DB load can cause performance issues in the DB instance. This alarm is not applicable to serverless DB instances."
  # Threshold Justification : "The maximum vCPU value is determined by the number of vCPU (virtual CPU) cores for your DB instance. Depending on the maximum vCPU, different values for the threshold can be appropriate. Ideally, DB load should not go above vCPU line."

  alarm_name                = format("cw-rds-%s-dbload", replace(lower(each.value.identifier), "/", "-"))
  alarm_description         = "DB load high; reduce concurrent work or scale."
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  metric_name               = "DBLoad"
  namespace                 = "AWS/RDS"
  statistic                 = "Average"
  period                    = 60
  dimensions = {
    DBInstanceIdentifier = each.value.identifier
  }
  evaluation_periods  = 15
  datapoints_to_alarm = 15
  threshold           = var.rds_db_load_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "missing"
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "rds_engine_uptime" {
  for_each = local.rds_clusters

  # Intent            : "This alarm is used to detect whether the Aurora writer DB instance is in downtime. This can prevent long-running failure in the writer instance that occurs because of a crash or failover."
  # Threshold Justification : "A failure event results in a brief interruption, during which read and write operations fail with an exception. However, service is typically restored in less than 60 seconds, and often less than 30 seconds."

  alarm_name                = format("cw-rds-%s-engineuptime", replace(lower(each.value.identifier), "/", "-"))
  alarm_description         = "Writer downtime detected; check failover or maintenance."
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  metric_name               = "EngineUptime"
  namespace                 = "AWS/RDS"
  statistic                 = "Average"
  period                    = 60
  dimensions = {
    Role                = "WRITER"
    DBClusterIdentifier = each.value.identifier
  }
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  threshold           = 0
  comparison_operator = "LessThanOrEqualToThreshold"
  treat_missing_data  = "breaching"
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "rds_freeable_memory" {
  for_each = local.rds_instances

  # Intent            : "This alarm is used to help prevent running out of memory which can result in rejected connections."
  # Threshold Justification : "Depending on the workload and instance class, different values for the threshold can be appropriate. Ideally, available memory should not go below 25% of total memory for prolonged periods. For Aurora, you can set the threshold close to 5%, because the metric approaching 0 means that the DB instance has scaled up as much as it can. You can analyze the historical behavior of this metric to determine sensible threshold levels."

  alarm_name                = format("cw-rds-%s-freeablememory", replace(lower(each.value.identifier), "/", "-"))
  alarm_description         = "Freeable memory low; optimize workload or scale memory."
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  metric_name               = "FreeableMemory"
  namespace                 = "AWS/RDS"
  statistic                 = "Average"
  period                    = 60
  dimensions = {
    DBInstanceIdentifier = each.value.identifier
  }
  evaluation_periods  = 15
  datapoints_to_alarm = 15
  threshold           = var.rds_freeable_memory_threshold
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "breaching"
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "rds_maximum_used_transaction_ids" {
  for_each = local.rds_instances

  # Intent            : "This alarm is used to help prevent transaction ID wraparound for PostgreSQL."
  # Threshold Justification : "Setting this threshold to 1 billion should give you time to investigate the problem. The default autovacuum_freeze_max_age value is 200 million. If the age of the oldest transaction is 1 billion, autovacuum is having a problem keeping this threshold below the target of 200 million transaction IDs."

  alarm_name                = format("cw-rds-%s-maximumusedtransactionids", replace(lower(each.value.identifier), "/", "-"))
  alarm_description         = "TXID age high; ensure autovacuum keeping up."
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  metric_name               = "MaximumUsedTransactionIDs"
  namespace                 = "AWS/RDS"
  statistic                 = "Average"
  period                    = 60
  dimensions = {
    DBInstanceIdentifier = each.value.identifier
  }
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  threshold           = var.rds_maximum_used_transaction_ids_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "missing"
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "rds_read_latency" {
  for_each = local.rds_instances

  # Intent            : "This alarm is used to detect high read latency. Database disks normally have a low read/write latency, but they can have issues that can cause high latency operations."
  # Threshold Justification : "The recommended threshold value for this alarm is highly dependent on your use case. Read latencies higher than 20 milliseconds are likely a cause for investigation. You can also set a higher threshold if your application can have higher latency for read operations. Review the criticality and requirements of read latency and analyze the historical behavior of this metric to determine sensible threshold levels."

  alarm_name                = format("cw-rds-%s-readlatency", replace(lower(each.value.identifier), "/", "-"))
  alarm_description         = "Read latency high; review I/O and storage performance."
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  metric_name               = "ReadLatency"
  namespace                 = "AWS/RDS"
  extended_statistic        = "p90"
  period                    = 60
  dimensions = {
    DBInstanceIdentifier = each.value.identifier
  }
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  threshold           = var.rds_read_latency_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "missing"
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "rds_storage_network_throughput" {
  for_each = local.rds_clusters

  # Intent            : "This alarm is used to detect high storage network throughput. Detecting high throughput can prevent network packet drops and degraded performance."
  # Threshold Justification : "You should calculate about 80%-90% of the total network bandwidth of the EC2 instance type, and then use that result as the threshold value to proactively take action before the network packets are affected. You can also review the criticality and requirements of storage network throughput and analyze the historical behavior of this metric to determine sensible threshold levels."

  alarm_name                = format("cw-rds-%s-storagenetworkthroughput", replace(lower(each.value.identifier), "/", "-"))
  alarm_description         = "Storage network throughput high; optimize I/O or scale instance."
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  metric_name               = "StorageNetworkThroughput"
  namespace                 = "AWS/RDS"
  statistic                 = "Average"
  period                    = 60
  dimensions = {
    Role                = "WRITER"
    DBClusterIdentifier = each.value.identifier
  }
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  threshold           = var.rds_storage_network_throughput_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "missing"
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "rds_write_latency" {
  for_each = local.rds_instances

  # Intent            : "This alarm is used to detect high write latency. Although database disks typically have low read/write latency, they may experience problems that cause high latency operations. Monitoring this will assure you the disk latency is as low as expected."
  # Threshold Justification : "The recommended threshold value for this alarm is highly dependent on your use case. Write latencies higher than 20 milliseconds are likely a cause for investigation. You can also set a higher threshold if your application can have a higher latency for write operations. Review the criticality and requirements of write latency and analyze the historical behavior of this metric to determine sensible threshold levels."

  alarm_name                = format("cw-rds-%s-writelatency", replace(lower(each.value.identifier), "/", "-"))
  alarm_description         = "Write latency is high. Review I/O usage, storage configuration, and instance capacity. For RDS, check EBS IOPS; for Aurora, consider I/O-Optimized storage."
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  metric_name               = "WriteLatency"
  namespace                 = "AWS/RDS"
  extended_statistic        = "p90"
  period                    = 60
  dimensions = {
    DBInstanceIdentifier = each.value.identifier
  }
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  threshold           = var.rds_write_latency_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "missing"
  tags                = var.tags
}
