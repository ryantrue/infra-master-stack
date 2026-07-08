#!/usr/bin/env bash
set -euo pipefail

MASTER_HOST="${PORTAINER_HOST:-portainer.example.com}"

cat <<INFO
Worker node mode is prepared.

On a future worker node:

1. Set in /srv/infra/.env:

   NODE_ROLE=worker

2. Deploy:

   /srv/infra/scripts/deploy.sh

3. In Portainer UI on the master node, add a Docker Standalone environment:

   Name: worker-name
   Environment URL: worker-ip-or-dns:9001

Notes:

- Do not add http:// or https:// to the Environment URL.
- Port 9001 on the worker must be reachable from the master.
- Do not expose worker 9001 to the public Internet.
- Keep worker access LAN/VPN/firewall restricted.

Master Portainer URL:

   https://$MASTER_HOST
INFO
