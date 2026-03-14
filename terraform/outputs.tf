output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.app_lb.dns_name
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.app_cdn.domain_name
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.app_db.endpoint
}

output "ecr_web_repository_url" {
  description = "ECR repository URL for web"
  value       = aws_ecr_repository.web.repository_url
}

output "ecr_api_repository_url" {
  description = "ECR repository URL for api"
  value       = aws_ecr_repository.api.repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.app_cluster.name
}

output "ecs_web_service_name" {
  description = "ECS web service name"
  value       = aws_ecs_service.web.name
}

output "ecs_api_service_name" {
  description = "ECS api service name"
  value       = aws_ecs_service.api.name
}
