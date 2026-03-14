# Operations Scripts

## ECS (start/stop/scale)

```bash
# All services
./ecs.sh start
./ecs.sh stop
./ecs.sh scale all 4

# Web only
./web_ecs.sh start
./web_ecs.sh stop
./web_ecs.sh scale 4

# API only
./api_ecs.sh start
./api_ecs.sh stop
./api_ecs.sh scale 3
```

## RDS (backup/list)

```bash
# Create a manual snapshot
./rds.sh backup

# List all snapshots
./rds.sh list
```
