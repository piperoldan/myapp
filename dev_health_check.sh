#!/usr/bin/env bash
set -euo pipefail

COMPOSE_NET="myapp_default"
DB_SERVICE_NAME="myapp-db-1"

echo "== Dev Health Check =="

# 1) Docker available
if ! command -v docker >/dev/null 2>&1; then
  echo "❌ Docker CLI not found."
  exit 1
fi
echo "✅ Docker CLI found"

# 2) Network exists
if ! docker network inspect "${COMPOSE_NET}" >/dev/null 2>&1; then
  echo "❌ Compose network '${COMPOSE_NET}' not found. Run: docker compose up -d"
  exit 1
fi
echo "✅ Network exists: ${COMPOSE_NET}"

# 3) Find running devcontainer (vsc-* image)
DEV_CONTAINER_NAME="$(
  docker ps --format '{{.Names}} {{.Image}}' \
    | awk '$2 ~ /^vsc-/ {print $1; exit}'
)"

if [[ -z "${DEV_CONTAINER_NAME}" ]]; then
  echo "❌ No running VS Code devcontainer found (image 'vsc-*')."
  echo "   Open VS Code → Reopen in Container, then re-run this script."
  exit 1
fi
echo "✅ Devcontainer running: ${DEV_CONTAINER_NAME}"

# 4) Devcontainer connected to compose network
if docker inspect -f '{{json .NetworkSettings.Networks}}' "${DEV_CONTAINER_NAME}" | grep -q "\"${COMPOSE_NET}\""; then
  echo "✅ Devcontainer connected to ${COMPOSE_NET}"
else
  echo "❌ Devcontainer NOT connected to ${COMPOSE_NET}"
  echo "   Fix: docker network connect ${COMPOSE_NET} ${DEV_CONTAINER_NAME}"
  exit 1
fi

# 5) DB container running
if docker ps --format '{{.Names}}' | grep -qx "${DB_SERVICE_NAME}"; then
  echo "✅ DB container running: ${DB_SERVICE_NAME}"
else
  echo "❌ DB container not running: ${DB_SERVICE_NAME}"
  echo "   Fix: docker compose up -d"
  exit 1
fi

# 6) Can the devcontainer reach db:3306 over the compose network?
echo "== Network reachability from devcontainer =="

docker exec "${DEV_CONTAINER_NAME}" bash -lc "python -c \"import socket; s=socket.socket(); s.settimeout(2); s.connect(('db',3306)); print('✅ OK db:3306'); s.close()\""

echo ""
echo "== Summary =="
echo "✅ Docker OK"
echo "✅ Compose network OK"
echo "✅ Devcontainer OK + connected"
echo "✅ DB container OK"
echo "✅ db:3306 reachable from devcontainer"
