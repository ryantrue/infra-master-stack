#!/usr/bin/env bash
set -euo pipefail

load_node_role() {
  local env_file="${1:-/srv/infra/.env}"

  if [[ -f "$env_file" ]]; then
    set -a
    # shellcheck disable=SC1090
    source "$env_file"
    set +a
  fi

  NODE_ROLE="${NODE_ROLE:-master}"

  case "$NODE_ROLE" in
    master|worker)
      export NODE_ROLE
      ;;
    *)
      echo "ERROR: unsupported NODE_ROLE='$NODE_ROLE'. Use: master or worker." >&2
      exit 1
      ;;
  esac
}

is_master() {
  [[ "${NODE_ROLE:-}" == "master" ]]
}

is_worker() {
  [[ "${NODE_ROLE:-}" == "worker" ]]
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  load_node_role "${1:-/srv/infra/.env}"
  echo "$NODE_ROLE"
fi
