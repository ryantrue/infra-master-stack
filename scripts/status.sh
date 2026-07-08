#!/usr/bin/env bash
set -euo pipefail

BASE="/srv/infra"

# shellcheck source=/srv/infra/scripts/node-role.sh
source "$BASE/scripts/node-role.sh"
load_node_role "$BASE/.env"

cd "$BASE"

echo "=== NODE ROLE ==="
echo "$NODE_ROLE"
echo

echo "=== HOST ==="
hostnamectl
echo

echo "=== DOCKER ==="
docker version --format 'Client={{.Client.Version}} Server={{.Server.Version}}'
docker compose version
echo

echo "=== CONTAINERS ==="
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
echo

echo "=== IMAGES ==="
docker images --format 'table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}'
echo

echo "=== NETWORKS ==="
docker network ls
echo

echo "=== LISTEN PORTS ==="
ss -tulpn | grep -E ':80|:443|:9000|:9443|:8123' || true
echo

echo "=== DOCKER DISK USAGE ==="
docker system df
echo

echo "=== INFRA TREE ==="
tree -a -L 3 "$BASE"
