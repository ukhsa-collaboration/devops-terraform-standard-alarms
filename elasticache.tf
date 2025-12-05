resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  for_each = local.elasticache_clusters

  # Missing fields    : "Threshold"
  # Intent            : "This alarm is used to detect high CPU utilization of ElastiCache hosts. It is useful to get a broad view of the CPU usage across the entire instance, including non-engine processes."
  # Threshold Justification : "Set the threshold to the percentage that reflects a critical CPU utilization level for your application. For Memcached, the engine can use up to num_threads cores. For Redis, the engine is largely single-threaded, but might use additional cores if available to accelerate I/O. In most cases, you can set the threshold to about 90% of your available CPU. Because Redis is single-threaded, the actual threshold value should be calculated as a fraction of the node's total capacity."

  alarm_name                = format("cw-elasticache-%s-cpuutilization", replace(lower(each.value.cluster_id), "/", "-"))
  alarm_description         = "High ElastiCache host CPU; consider scaling nodes or adding replicas/shards."
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/ElastiCache"
  statistic                 = "Average"
  period                    = 60
  dimensions = {
    CacheClusterId = each.value.cluster_id
    CacheNodeId    = length(each.value.node_ids) > 0 ? each.value.node_ids[0] : "0001"
  }
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  threshold           = var.elasticache_cpu_utilization_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "missing"
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "curr_connections" {
  for_each = local.elasticache_clusters

  # Missing fields    : "Threshold"
  # Intent            : "The alarm helps you identify high connection counts that could impact the performance and stability of your ElastiCache cluster."
  # Threshold Justification : "The recommended threshold value for this alarm is highly dependent on the acceptable range of connections for your cluster. Review the capacity and the expected workload of your ElastiCache cluster and analyze the historical connection counts during regular usage to establish a baseline, and then select a threshold accordingly. Remember that each node can support up to 65,000 concurrent connections."

  alarm_name                = format("cw-elasticache-%s-currconnections", replace(lower(each.value.cluster_id), "/", "-"))
  alarm_description         = "ElastiCache connections high; review client pooling/idle timeouts and scale if needed."
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  metric_name               = "CurrConnections"
  namespace                 = "AWS/ElastiCache"
  statistic                 = "Average"
  period                    = 60
  dimensions = {
    CacheClusterId = each.value.cluster_id
    CacheNodeId    = length(each.value.node_ids) > 0 ? each.value.node_ids[0] : "0001"
  }
  evaluation_periods  = 10
  datapoints_to_alarm = 10
  threshold           = var.elasticache_curr_connections_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "missing"
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "database_memory_usage_percentage" {
  for_each = local.elasticache_clusters

  # Missing fields    : "Threshold"
  # Intent            : "This alarm is used to detect high memory utilization of your cluster so that you can avoid failures when writing to your cluster. It is useful to know when you’ll need to scale up your cluster if your application does not expect to experience evictions."
  # Threshold Justification : "Depending on your application’s memory requirements and the memory capacity of your ElastiCache cluster, you should set the threshold to the percentage that reflects the critical level of memory usage of the cluster. You can use historical memory usage data as reference for acceptable memory usage threshold."

  alarm_name                = format("cw-elasticache-%s-databasememoryusagepercentage", replace(lower(each.value.cluster_id), "/", "-"))
  alarm_description         = "ElastiCache memory near limit; expect evictions or write failures—scale capacity or shards."
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  metric_name               = "DatabaseMemoryUsagePercentage"
  namespace                 = "AWS/ElastiCache"
  statistic                 = "Average"
  period                    = 60
  dimensions = {
    CacheClusterId = each.value.cluster_id
  }
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  threshold           = var.elasticache_database_memory_usage_percentage_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "missing"
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "engine_cpu_utilization" {
  for_each = local.elasticache_clusters

  # Intent            : "This alarm is used to detect high CPU utilization of the Redis engine thread. It is useful if you want to monitor the CPU usage of the database engine itself."
  # Threshold Justification : "Set the threshold to a percentage that reflects the critical engine CPU utilization level for your application. You can benchmark your cluster using your application and expected workload to correlate EngineCPUUtilization and performance as a reference, and then set the threshold accordingly. In most cases, you can set the threshold to about 90% of your available CPU."

  alarm_name                = format("cw-elasticache-%s-enginecpuutilization", replace(lower(each.value.cluster_id), "/", "-"))
  alarm_description         = "Redis engine CPU high; check hot keys/commands, add shards or replicas."
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  metric_name               = "EngineCPUUtilization"
  namespace                 = "AWS/ElastiCache"
  statistic                 = "Average"
  period                    = 60
  dimensions = {
    CacheClusterId = each.value.cluster_id
  }
  evaluation_periods  = 5
  datapoints_to_alarm = 5
  threshold           = var.elasticache_engine_cpu_utilization_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "missing"
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "replication_lag" {
  for_each = local.elasticache_clusters

  # Missing fields    : "Threshold"
  # Intent            : "This alarm is used to detect a delay between data updates on the primary node and their synchronization to replica node. It helps to ensure data consistency of a read replica cluster node."
  # Threshold Justification : "Set the threshold according to your application's requirements and the potential impact of replication lag. You should consider your application's expected write rates and network conditions for the acceptable replication lag."

  alarm_name                = format("cw-elasticache-%s-replicationlag", replace(lower(each.value.cluster_id), "/", "-"))
  alarm_description         = "ElastiCache replication lag high; investigate write load and scale replicas/shards."
  actions_enabled           = true
  ok_actions                = local.alarm_actions
  alarm_actions             = local.alarm_actions
  insufficient_data_actions = local.alarm_actions
  metric_name               = "ReplicationLag"
  namespace                 = "AWS/ElastiCache"
  statistic                 = "Average"
  period                    = 60
  dimensions = {
    CacheClusterId = each.value.cluster_id
  }
  evaluation_periods  = 15
  datapoints_to_alarm = 15
  threshold           = var.elasticache_replication_lag_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "missing"
  tags                = var.tags
}
