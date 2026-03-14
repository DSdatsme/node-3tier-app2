variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "nodeapp"
}

variable "environment" {
  description = "Environment name (e.g., production, staging)"
  type        = string
  default     = "production"
}

variable "owner" {
  description = "Team or person responsible for these resources"
  type        = string
  default     = "darshit"
}

# START: Networking variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}
# END: Networking variables

# START: Database variables
variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "node3tierdb"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "dbadmin"
}

variable "db_backup_retention" {
  description = "Number of days to retain DB backups"
  type        = number
  default     = 7
}

variable "db_backup_window" {
  description = "Preferred backup window"
  type        = string
  default     = "03:00-04:00"
}

variable "db_maintenance_window" {
  description = "Preferred maintenance window"
  type        = string
  default     = "sun:04:00-sun:05:00"
}
# END: Database variables

# START: ECS variables
variable "ecs_web_desired_count" {
  description = "Desired number of web ECS tasks"
  type        = number
  default     = 2
}

variable "ecs_api_desired_count" {
  description = "Desired number of api ECS tasks"
  type        = number
  default     = 2
}

variable "ecs_web_cpu" {
  description = "CPU units for web task (1 vCPU = 1024)"
  type        = number
  default     = 256
}

variable "ecs_web_memory" {
  description = "Memory (MiB) for web task"
  type        = number
  default     = 512
}

variable "ecs_api_cpu" {
  description = "CPU units for api task"
  type        = number
  default     = 256
}

variable "ecs_api_memory" {
  description = "Memory (MiB) for api task"
  type        = number
  default     = 512
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}
# END: ECS variables

# START: CloudFront variables
variable "alarm_email" {
  description = "Email for CloudWatch alarm notifications"
  type        = string
  default     = ""
}

variable "cloudfront_origin_secret" {
  description = "Secret header value for CloudFront-to-ALB validation"
  type        = string
  sensitive   = true
}
# END: CloudFront variables

# START: ECR variables
variable "ecr_image_retention_count" {
  description = "Number of images to retain in ECR"
  type        = number
  default     = 30
}
# END: ECR variables
