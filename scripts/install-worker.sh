#!/usr/bin/env bash
set -euo pipefail

BASE="/srv/infra"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ "$(hostname)" == "infra-master" && "${FORCE:-0}" != "1" ]]; then
  echo "ERROR: refusing to install worker mode on infra-master."
  echo "This script is intended for future worker nodes."
  echo "Use FORCE=1 only if you really know what you are doing."
  exit 1
fi

if [[ -f "$BASE/.env" ]] && grep -q '^NODE_ROLE=master$' "$BASE/.env" && [[ "${FORCE:-0}" != "1" ]]; then
  echo "ERROR: existing /srv/infra/.env says NODE_ROLE=master."
  echo "Refusing to overwrite a master node."
  exit 1
fi

echo "=== Creating worker runtime directories ==="
sudo mkdir -p "$BASE"/{compose,scripts,secrets}

echo
echo "=== Installing worker compose and scripts ==="
sudo cp -a "$REPO_DIR/compose/worker.compose.yml" "$BASE/compose/"
sudo cp -a "$REPO_DIR/scripts/"*.sh "$BASE/scripts/"
sudo chmod +x "$BASE/scripts/"*.sh

if [[ ! -f "$BASE/.env" ]]; then
  echo
  echo "=== Creating worker .env ==="
  sudo cp -a "$REPO_DIR/.env.example" "$BASE/.env"
fi

echo
echo "=== Setting NODE_ROLE=worker ==="
sudo python3 - <<'INNER_PY'
from pathlib import Path

p = Path("/srv/infra/.env")
lines = p.read_text().splitlines() if p.exists() else []
lines = [line for line in lines if not line.startswith("NODE_ROLE=")]

if lines and lines[-1].strip():
    lines.append("")

lines.append("NODE_ROLE=worker")
p.write_text("\n".join(lines) + "\n")
INNER_PY

sudo chown "$USER:$USER" "$BASE/.env"
chmod 600 "$BASE/.env"

echo
echo "=== Worker env ==="
grep -E '^(NODE_ROLE|TZ)=' "$BASE/.env" || true

echo
echo "Worker install files are ready."
echo "Deploy with:"
echo
echo "  $BASE/scripts/deploy.sh"
