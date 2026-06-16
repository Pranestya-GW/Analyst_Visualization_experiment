#!/bin/bash
# ============================================================================
# Stop BI tools
# Usage: ./stop.sh           → stop everything
#        ./stop.sh metabase  → stop only Metabase
#        ./stop.sh clean     → stop & remove all data
# ============================================================================
set -e

RED='\033[0;31m'
NC='\033[0m'

if [ "$1" = "metabase" ]; then
    docker compose -f docker-compose-metabase.yml down
    echo "Metabase stopped"

elif [ "$1" = "superset" ]; then
    docker compose -f docker-compose-superset.yml down
    echo "Superset stopped"

elif [ "$1" = "grafana" ]; then
    docker compose -f docker-compose-grafana.yml down
    echo "Grafana stopped"

elif [ "$1" = "redash" ]; then
    docker compose -f docker-compose-redash.yml down
    echo "Redash stopped"

elif [ "$1" = "clean" ]; then
    echo -e "${RED}Removing all containers, volumes, and data...${NC}"
    docker compose -f docker-compose-all.yml down -v 2>/dev/null || true
    docker compose -f docker-compose-shared-db.yml down -v 2>/dev/null || true
    docker compose -f docker-compose-metabase.yml down -v 2>/dev/null || true
    docker compose -f docker-compose-superset.yml down -v 2>/dev/null || true
    docker compose -f docker-compose-grafana.yml down -v 2>/dev/null || true
    docker compose -f docker-compose-redash.yml down -v 2>/dev/null || true
    docker network rm bi-network 2>/dev/null || true
    echo "All cleaned up."

else
    docker compose -f docker-compose-all.yml down
    echo "All tools stopped (data preserved)."
    echo "Use './stop.sh clean' to remove all data."
fi
