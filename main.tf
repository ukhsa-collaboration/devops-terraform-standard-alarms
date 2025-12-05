data "aws_resourcegroupstaggingapi_resources" "ecs_services" {
  resource_type_filters = ["ecs:service"]

  tag_filter {
    key    = local.project_tag_key
    values = local.project_tag_values
  }
}

data "aws_resourcegroupstaggingapi_resources" "lambda_functions" {
  resource_type_filters = ["lambda:function"]

  tag_filter {
    key    = local.project_tag_key
    values = local.project_tag_values
  }
}

data "aws_resourcegroupstaggingapi_resources" "wafv2_web_acls" {
  resource_type_filters = [
    "wafv2:regional/webacl",
    "wafv2:global/webacl",
  ]

  tag_filter {
    key    = local.project_tag_key
    values = local.project_tag_values
  }
}

data "aws_resourcegroupstaggingapi_resources" "rds_instances" {
  resource_type_filters = ["rds:db"]

  tag_filter {
    key    = local.project_tag_key
    values = local.project_tag_values
  }
}

data "aws_resourcegroupstaggingapi_resources" "rds_clusters" {
  resource_type_filters = ["rds:cluster"]

  tag_filter {
    key    = local.project_tag_key
    values = local.project_tag_values
  }
}

data "aws_resourcegroupstaggingapi_resources" "elasticache_clusters" {
  resource_type_filters = ["elasticache:cluster"]

  tag_filter {
    key    = local.project_tag_key
    values = local.project_tag_values
  }
}

data "aws_resourcegroupstaggingapi_resources" "nat_gateways" {
  resource_type_filters = ["ec2:natgateway"]

  tag_filter {
    key    = local.project_tag_key
    values = local.project_tag_values
  }
}

data "aws_resourcegroupstaggingapi_resources" "sqs_queues" {
  resource_type_filters = ["sqs:queue"]

  tag_filter {
    key    = local.project_tag_key
    values = local.project_tag_values
  }
}

data "aws_resourcegroupstaggingapi_resources" "sns_topics" {
  resource_type_filters = ["sns:topic"]

  tag_filter {
    key    = local.project_tag_key
    values = local.project_tag_values
  }
}

data "aws_resourcegroupstaggingapi_resources" "cloudfront_distributions" {
  region                = "us-east-1"
  resource_type_filters = ["cloudfront:distribution"]

  tag_filter {
    key    = local.project_tag_key
    values = local.project_tag_values
  }
}

data "aws_resourcegroupstaggingapi_resources" "acm_certificates" {
  region                = "us-east-1"
  resource_type_filters = ["acm:certificate"]

  tag_filter {
    key    = local.project_tag_key
    values = local.project_tag_values
  }
}

data "aws_resourcegroupstaggingapi_resources" "acm_certificates_regional" {
  resource_type_filters = ["acm:certificate"]

  tag_filter {
    key    = local.project_tag_key
    values = local.project_tag_values
  }
}

data "aws_resourcegroupstaggingapi_resources" "application_load_balancers" {
  resource_type_filters = ["elasticloadbalancing:loadbalancer"]

  tag_filter {
    key    = local.project_tag_key
    values = local.project_tag_values
  }
}

data "aws_resourcegroupstaggingapi_resources" "application_load_balancer_target_groups" {
  resource_type_filters = ["elasticloadbalancing:targetgroup"]

  tag_filter {
    key    = local.project_tag_key
    values = local.project_tag_values
  }
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_elasticache_cluster" "discovered" {
  for_each = {
    for mapping in data.aws_resourcegroupstaggingapi_resources.elasticache_clusters.resource_tag_mapping_list :
    element(split(":", mapping.resource_arn), length(split(":", mapping.resource_arn)) - 1) => {
      arn = mapping.resource_arn
    }
  }

  cluster_id = replace(each.key, "cluster:", "")
}

locals {
  project_tag_key    = coalesce(var.project_tag_key, "lz:Service")
  project_tag_values = var.project_tag_value == null ? null : [var.project_tag_value]

  ecs_services = {
    for mapping in data.aws_resourcegroupstaggingapi_resources.ecs_services.resource_tag_mapping_list :
    mapping.resource_arn => {
      cluster_name = element(split("/", mapping.resource_arn), length(split("/", mapping.resource_arn)) - 2)
      service_name = element(split("/", mapping.resource_arn), length(split("/", mapping.resource_arn)) - 1)
    }
  }

  lambda_functions = {
    for mapping in data.aws_resourcegroupstaggingapi_resources.lambda_functions.resource_tag_mapping_list :
    mapping.resource_arn => {
      function_name = element(split(":", mapping.resource_arn), length(split(":", mapping.resource_arn)) - 1)
    }
  }

  cloudfront_distributions = {
    for mapping in data.aws_resourcegroupstaggingapi_resources.cloudfront_distributions.resource_tag_mapping_list :
    mapping.resource_arn => {
      distribution_id = element(split("/", mapping.resource_arn), length(split("/", mapping.resource_arn)) - 1)
    }
  }

  wafv2_web_acls = {
    for mapping in data.aws_resourcegroupstaggingapi_resources.wafv2_web_acls.resource_tag_mapping_list :
    mapping.resource_arn => {
      name             = element(split("/", mapping.resource_arn), length(split("/", mapping.resource_arn)) - 2)
      scope            = element(split(":", mapping.resource_arn), 3)
      region_dimension = element(split(":", mapping.resource_arn), 3) == "global" ? "Global" : element(split(":", mapping.resource_arn), 3)
    }
  }

  rds_instances = {
    for mapping in data.aws_resourcegroupstaggingapi_resources.rds_instances.resource_tag_mapping_list :
    mapping.resource_arn => {
      identifier = element(split(":", mapping.resource_arn), length(split(":", mapping.resource_arn)) - 1)
    }
  }

  rds_clusters = {
    for mapping in data.aws_resourcegroupstaggingapi_resources.rds_clusters.resource_tag_mapping_list :
    mapping.resource_arn => {
      identifier = element(split(":", mapping.resource_arn), length(split(":", mapping.resource_arn)) - 1)
    }
  }

  elasticache_clusters = {
    for id, cluster in data.aws_elasticache_cluster.discovered :
    id => {
      cluster_id = cluster.id
      node_ids   = cluster.cache_nodes[*].id
    }
  }

  nat_gateways = {
    for mapping in data.aws_resourcegroupstaggingapi_resources.nat_gateways.resource_tag_mapping_list :
    mapping.resource_arn => {
      nat_gateway_id = element(split("/", mapping.resource_arn), length(split("/", mapping.resource_arn)) - 1)
    }
  }

  sqs_queues = {
    for mapping in data.aws_resourcegroupstaggingapi_resources.sqs_queues.resource_tag_mapping_list :
    mapping.resource_arn => {
      queue_name = element(split(":", mapping.resource_arn), length(split(":", mapping.resource_arn)) - 1)
    }
  }

  sns_topics = {
    for mapping in data.aws_resourcegroupstaggingapi_resources.sns_topics.resource_tag_mapping_list :
    mapping.resource_arn => {
      topic_name = element(split(":", mapping.resource_arn), length(split(":", mapping.resource_arn)) - 1)
    }
    if mapping.resource_arn != local.sns_topic_arn
  }

  acm_certificates = {
    for mapping in data.aws_resourcegroupstaggingapi_resources.acm_certificates.resource_tag_mapping_list :
    mapping.resource_arn => {
      certificate_arn = mapping.resource_arn
    }
  }

  acm_certificates_regional = {
    for mapping in data.aws_resourcegroupstaggingapi_resources.acm_certificates_regional.resource_tag_mapping_list :
    mapping.resource_arn => {
      certificate_arn = mapping.resource_arn
    }
  }

  application_load_balancers = {
    for mapping in data.aws_resourcegroupstaggingapi_resources.application_load_balancers.resource_tag_mapping_list :
    mapping.resource_arn => {
      load_balancer_dimension = element(split("loadbalancer/", mapping.resource_arn), 1)
      load_balancer_name      = replace(lower(element(split("loadbalancer/", mapping.resource_arn), 1)), "/", "-")
    }
  }

  application_load_balancer_target_groups = {
    for mapping in data.aws_resourcegroupstaggingapi_resources.application_load_balancer_target_groups.resource_tag_mapping_list :
    mapping.resource_arn => {
      target_group_dimension = format("targetgroup/%s", element(split("targetgroup/", mapping.resource_arn), 1))
      target_group_name      = replace(lower(format("targetgroup/%s", element(split("targetgroup/", mapping.resource_arn), 1))), "/", "-")
    }
  }

  sns_topic_arn = coalesce(
    var.sns_topic_arn,
    format(
      "arn:aws:sns:%s:%s:aw-phe-%s-sns-cloudwatch_alarms",
      data.aws_region.current.region,
      data.aws_caller_identity.current.account_id,
      data.aws_region.current.region
    )
  )

  alarm_actions = compact([local.sns_topic_arn])
}
