resource "aws_service_discovery_private_dns_namespace" "app" {
  name        = "${var.project_name}.local"
  description = "Service discovery namespace for ${var.project_name}"
  vpc         = aws_vpc.app_vpc.id

  tags = {
    Name      = "${var.project_name}.local"
    Component = "networking"
  }
}

resource "aws_service_discovery_service" "api" {
  name = "api"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.app.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  tags = {
    Name      = "${var.project_name}-api-discovery"
    Component = "api"
  }
}
