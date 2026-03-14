#!/bin/bash
set -e

# Variables
CLUSTER="nodeapp-cluster"
WEB_SERVICE="nodeapp-web"
API_SERVICE="nodeapp-api"
REGION="us-east-1"
DEFAULT_COUNT=2

usage() {
  echo "Usage: $0 {start|stop|scale} [service] [count]"
  echo ""
  echo "Commands:"
  echo "  start [service]         Start services (desired count: $DEFAULT_COUNT)"
  echo "  stop  [service]         Stop services (desired count: 0)"
  echo "  scale [service] [count] Scale services to the given count"
  echo ""
  echo "Service: web | api | all (default: all)"
  exit 1
}

update_service() {
  local service=$1
  local count=$2
  echo "Setting $service desired count to $count..."

  aws ecs update-service \
    --cluster "$CLUSTER" \
    --service "$service" \
    --desired-count "$count" \
    --region "$REGION" \
    --query 'service.{name:serviceName,desired:desiredCount}' \
    --output table
}

resolve_and_update() {
  local target=${1:-all}
  local count=$2

  case "$target" in
    web) update_service "$WEB_SERVICE" "$count" ;;
    api) update_service "$API_SERVICE" "$count" ;;
    all)
      update_service "$WEB_SERVICE" "$count"
      update_service "$API_SERVICE" "$count"
      ;;
    *) echo "Error: unknown service '$target'"; usage ;;
  esac
}

case "${1}" in
  start)
    resolve_and_update "${2}" "$DEFAULT_COUNT"
    ;;
  stop)
    resolve_and_update "${2}" 0
    ;;
  scale)
    service="${2:-all}"
    count="${3}"
    if [ -z "$count" ]; then
      echo "Error: scale requires a count argument"
      usage
    fi
    resolve_and_update "$service" "$count"
    ;;
  *)
    usage
    ;;
esac
