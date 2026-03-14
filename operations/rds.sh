#!/bin/bash
set -e

# Variables
DB_INSTANCE="nodeapp-db"
REGION="us-east-1"

usage() {
  echo "Usage: $0 {backup|list}"
  echo ""
  echo "Commands:"
  echo "  backup  Create a manual snapshot of the database"
  echo "  list    List all available snapshots"
  exit 1
}

case "${1}" in
  backup)
    SNAPSHOT_ID="${DB_INSTANCE}-$(date +%Y%m%d-%H%M%S)"
    echo "Creating snapshot: $SNAPSHOT_ID"

    aws rds create-db-snapshot \
      --db-instance-identifier "$DB_INSTANCE" \
      --db-snapshot-identifier "$SNAPSHOT_ID" \
      --region "$REGION" \
      --query 'DBSnapshot.{id:DBSnapshotIdentifier,status:Status,created:SnapshotCreateTime}' \
      --output table

    echo "Snapshot creation initiated. Use '$0 list' to check status."
    ;;
  list)
    echo "Snapshots for $DB_INSTANCE:"

    aws rds describe-db-snapshots \
      --db-instance-identifier "$DB_INSTANCE" \
      --region "$REGION" \
      --query 'DBSnapshots[*].{id:DBSnapshotIdentifier,status:Status,created:SnapshotCreateTime,type:SnapshotType}' \
      --output table
    ;;
  *)
    usage
    ;;
esac
