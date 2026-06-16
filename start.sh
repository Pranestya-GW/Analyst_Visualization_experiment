#!/bin/bash
# ============================================================================
# Start all BI tools
# Usage: ./start.sh           → start everything
#        ./start.sh metabase  → start only Metabase
# ============================================================================
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  BI Tools Launcher${NC}"
echo -e "${BLUE}============================================${NC}"

# Ensure shared network exists
docker network create bi-network 2>/dev/null || true

if [ "$1" = "metabase" ]; then
    echo -e "${GREEN}→ Starting Metabase...${NC}"
    docker compose -f docker-compose-shared-db.yml up -d
    docker compose -f docker-compose-metabase.yml up -d
    echo ""
    echo "  Metabase:  http://localhost:5000"

elif [ "$1" = "superset" ]; then
    echo -e "${GREEN}→ Starting Superset...${NC}"
    docker compose -f docker-compose-shared-db.yml up -d
    docker compose -f docker-compose-superset.yml up -d
    echo ""
    echo "  Superset:  http://localhost:8088  (admin / admin)"

elif [ "$1" = "grafana" ]; then
    echo -e "${GREEN}→ Starting Grafana...${NC}"
    docker compose -f docker-compose-shared-db.yml up -d
    docker compose -f docker-compose-grafana.yml up -d
    echo ""
    echo "  Grafana:   http://localhost:3000  (admin / admin)"

elif [ "$1" = "redash" ]; then
    echo -e "${GREEN}→ Starting Redash...${NC}"
    docker compose -f docker-compose-redash.yml up -d
    echo "  Waiting for Redash to boot..."
    sleep 10
    docker exec -it redash_server create_db 2>/dev/null || true
    echo ""
    echo "  Redash:    http://localhost:5001"

else
    echo -e "${GREEN}→ Starting all tools...${NC}"
    docker compose -f docker-compose-all.yml up -d
    echo "  Waiting for Redash to boot..."
    sleep 10
    docker exec -it redash_server create_db 2>/dev/null || true
    echo ""
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}  All tools running:${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo "  Shared DB:  localhost:5439  (analyst / analyst_pass / analytics)"
    echo "  Metabase:   http://localhost:5000"
    echo "  Superset:   http://localhost:8088  (admin / admin)"
    echo "  Grafana:    http://localhost:3000  (admin / admin)"
    echo "  Redash:     http://localhost:5001"
fi

echo ""
echo -e "  ${GREEN}Status:${NC} docker ps --filter 'name=bi_\|metabase\|superset\|grafana\|redash'"
echo ""
