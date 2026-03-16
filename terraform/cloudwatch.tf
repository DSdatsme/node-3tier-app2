# Log Groups
resource "aws_cloudwatch_log_group" "web" {
  name              = "/ecs/${var.project_name}-web"
  retention_in_days = var.log_retention_days

  tags = {
    Name      = "${var.project_name}-web-logs"
    Component = "web"
  }
}

resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/${var.project_name}-api"
  retention_in_days = var.log_retention_days

  tags = {
    Name      = "${var.project_name}-api-logs"
    Component = "api"
  }
}

# SNS Topic for alarm notifications
resource "aws_sns_topic" "alarms" {
  name = "${var.project_name}-alarms"

  tags = {
    Name      = "${var.project_name}-alarms"
    Component = "monitoring"
  }
}

resource "aws_sns_topic_subscription" "alarm_email" {
  count     = var.alarm_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# Alarms
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${var.project_name}-alb-5xx-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "ALB 5xx errors exceeded threshold"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    LoadBalancer = aws_lb.app_lb.arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "${var.project_name}-rds-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RDS CPU utilization exceeded 80%"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.app_db.identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_storage" {
  alarm_name          = "${var.project_name}-rds-storage-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 4294967296 # 4 GB in bytes
  alarm_description   = "RDS free storage below 4GB"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.app_db.identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_web_task_count" {
  alarm_name          = "${var.project_name}-ecs-web-tasks-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "RunningTaskCount"
  namespace           = "ECS/ContainerInsights"
  period              = 60
  statistic           = "Average"
  threshold           = 2
  alarm_description   = "Web service running containers dropped below 2"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    ServiceName = aws_ecs_service.web.name
    ClusterName = aws_ecs_cluster.app_cluster.name
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_api_task_count" {
  alarm_name          = "${var.project_name}-ecs-api-tasks-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "RunningTaskCount"
  namespace           = "ECS/ContainerInsights"
  period              = 60
  statistic           = "Average"
  threshold           = 2
  alarm_description   = "API service running containers dropped below 2"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    ServiceName = aws_ecs_service.api.name
    ClusterName = aws_ecs_cluster.app_cluster.name
  }
}

# Dashboard
resource "aws_cloudwatch_dashboard" "app_dashboard" {
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title = "ECS CPU Utilization"
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", "${var.project_name}-web", "ClusterName", aws_ecs_cluster.app_cluster.name, { stat = "Average" }],
            ["AWS/ECS", "CPUUtilization", "ServiceName", "${var.project_name}-api", "ClusterName", aws_ecs_cluster.app_cluster.name, { stat = "Average" }]
          ]
          period = 300
          region = var.aws_region
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title = "ECS Memory Utilization"
          metrics = [
            ["AWS/ECS", "MemoryUtilization", "ServiceName", "${var.project_name}-web", "ClusterName", aws_ecs_cluster.app_cluster.name, { stat = "Average" }],
            ["AWS/ECS", "MemoryUtilization", "ServiceName", "${var.project_name}-api", "ClusterName", aws_ecs_cluster.app_cluster.name, { stat = "Average" }]
          ]
          period = 300
          region = var.aws_region
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title = "ECS Running Task Count"
          metrics = [
            ["ECS/ContainerInsights", "RunningTaskCount", "ServiceName", aws_ecs_service.web.name, "ClusterName", aws_ecs_cluster.app_cluster.name, { stat = "Average" }],
            ["ECS/ContainerInsights", "RunningTaskCount", "ServiceName", aws_ecs_service.api.name, "ClusterName", aws_ecs_cluster.app_cluster.name, { stat = "Average" }]
          ]
          period = 60
          region = var.aws_region
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title = "ALB Request Count & Latency"
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_lb.app_lb.arn_suffix, { stat = "Sum" }],
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", aws_lb.app_lb.arn_suffix, { stat = "p50" }],
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", aws_lb.app_lb.arn_suffix, { stat = "p95" }],
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", aws_lb.app_lb.arn_suffix, { stat = "p99" }]
          ]
          period = 300
          region = var.aws_region
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          title = "ALB Error Rates"
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_ELB_4XX_Count", "LoadBalancer", aws_lb.app_lb.arn_suffix, { stat = "Sum" }],
            ["AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", aws_lb.app_lb.arn_suffix, { stat = "Sum" }],
            ["AWS/ApplicationELB", "HealthyHostCount", "LoadBalancer", aws_lb.app_lb.arn_suffix, "TargetGroup", aws_lb_target_group.web.arn_suffix, { stat = "Average" }],
            ["AWS/ApplicationELB", "HealthyHostCount", "LoadBalancer", aws_lb.app_lb.arn_suffix, "TargetGroup", aws_lb_target_group.api.arn_suffix, { stat = "Average" }]
          ]
          period = 300
          region = var.aws_region
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 18
        width  = 12
        height = 6
        properties = {
          title = "RDS Metrics"
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", aws_db_instance.app_db.identifier, { stat = "Average" }],
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", aws_db_instance.app_db.identifier, { stat = "Average" }],
            ["AWS/RDS", "ReadLatency", "DBInstanceIdentifier", aws_db_instance.app_db.identifier, { stat = "Average" }],
            ["AWS/RDS", "WriteLatency", "DBInstanceIdentifier", aws_db_instance.app_db.identifier, { stat = "Average" }]
          ]
          period = 300
          region = var.aws_region
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 18
        width  = 12
        height = 6
        properties = {
          title = "RDS Free Storage Space"
          metrics = [
            ["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", aws_db_instance.app_db.identifier, { stat = "Average" }]
          ]
          period = 300
          region = var.aws_region
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6
        properties = {
          title = "CloudFront Metrics"
          metrics = [
            ["AWS/CloudFront", "Requests", "DistributionId", aws_cloudfront_distribution.app_cdn.id, "Region", "Global", { stat = "Sum" }],
            ["AWS/CloudFront", "BytesDownloaded", "DistributionId", aws_cloudfront_distribution.app_cdn.id, "Region", "Global", { stat = "Sum" }],
            ["AWS/CloudFront", "4xxErrorRate", "DistributionId", aws_cloudfront_distribution.app_cdn.id, "Region", "Global", { stat = "Average" }],
            ["AWS/CloudFront", "5xxErrorRate", "DistributionId", aws_cloudfront_distribution.app_cdn.id, "Region", "Global", { stat = "Average" }]
          ]
          period = 300
          region = var.aws_region
        }
      }
    ]
  })
}
