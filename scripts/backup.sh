#!/usr/bin/env bash
set -euo pipefail

BASE="/srv/infra"
TS="$(date +%Y%m%d-%H%M%S)"
META_DIR="$BASE/backups/.metadata-$TS"
ARCHIVE="$BASE/backups/infra-backup-$TS.tar.gz"

mkdir -p "$META_DIR"

cleanup() {
  rm -rf "$META_DIR"
}
trap cleanup EXIT

echo "=== Collecting metadata ==="
docker ps -a > "$META_DIR/docker-ps-a.txt"
docker images > "$META_DIR/docker-images.txt"
docker network inspect proxy > "$META_DIR/proxy-network.json" 2>/dev/null || true

{
  echo "=== /srv/infra top-level ==="
  tree -a -L 2 "$BASE" -I 'backups|appdata' 2>/dev/null || true

  echo
  echo "=== compose ==="
  tree -a -L 3 "$BASE/compose" 2>/dev/null || true

  echo
  echo "=== scripts ==="
  tree -a -L 2 "$BASE/scripts" 2>/dev/null || true

  echo
  echo "=== traefik appdata ==="
  tree -a -L 3 "$BASE/appdata/traefik" 2>/dev/null || true
} > "$META_DIR/tree.txt"

echo "=== Creating archive ==="
cd "$BASE"

sudo tar \
  --exclude='backups' \
  -czf "$ARCHIVE" \
  compose \
  appdata/traefik \
  appdata/portainer \
  secrets \
  scripts \
  .env \
  .gitignore \
  -C "$META_DIR" .

sudo chown "$USER:$USER" "$ARCHIVE"

echo
echo "Backup created:"
ls -lh "$ARCHIVE"
