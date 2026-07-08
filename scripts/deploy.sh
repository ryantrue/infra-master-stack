#!/usr/bin/env bash
set -euo pipefail

BASE="/srv/infra"
COMPOSE_DIR="$BASE/compose"

# shellcheck source=/srv/infra/scripts/node-role.sh
source "$BASE/scripts/node-role.sh"
load_node_role "$BASE/.env"

echo "=== Node role: $NODE_ROLE ==="

case "$NODE_ROLE" in
  master)
    cd "$COMPOSE_DIR"

    echo
    echo "=== Ensuring proxy network exists ==="
    docker network inspect proxy >/dev/null 2>&1 || docker network create proxy

    echo
    echo "=== Deploy Traefik ==="
    docker compose --env-file "$BASE/.env" -f traefik.compose.yml up -d

    echo
    echo "=== Deploy Portainer ==="
    docker compose --env-file "$BASE/.env" -f portainer.compose.yml up -d
    ;;

  worker)
    cd "$COMPOSE_DIR"

    echo
    echo "=== Deploy Portainer Agent ==="
    docker compose --env-file "$BASE/.env" -f worker.compose.yml up -d
    ;;

  *)
    echo "ERROR: unsupported NODE_ROLE='$NODE_ROLE'" >&2
    exit 1
    ;;
esac

echo
echo "=== Result ==="
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
