#!/usr/bin/env bash
set -euo pipefail

SAVEPOINT_TAG="pre-change-savepoint"
COMPOSE_NET="myapp_default"

echo "== PANIC RESTORE: back to last savepoint =="

git fetch --tags origin
git reset --hard "${SAVEPOINT_TAG}"

echo ""
echo "== Docker network fix (dev container ↔ compose network) =="

if command -v docker >/dev/null 2>&1; then
  if docker network inspect "${COMPOSE_NET}" >/dev/null 2>&1; then
    # Try to detect a running VS Code devcontainer (images usually start with vsc-)
    DEV_CONTAINER_NAME="$(
      docker ps --format '{{.Names}} {{.Image}}' \
        | awk '$2 ~ /^vsc-/ {print $1; exit}'
    )"

    if [[ -n "${DEV_CONTAINER_NAME}" ]]; then
      if docker inspect -f '{{json .NetworkSettings.Networks}}' "${DEV_CONTAINER_NAME}" | grep -q "\"${COMPOSE_NET}\""; then
        echo "Dev container already connected to ${COMPOSE_NET}: ${DEV_CONTAINER_NAME}"
      else
        echo "Connecting dev container to ${COMPOSE_NET}: ${DEV_CONTAINER_NAME}"
        docker network connect "${COMPOSE_NET}" "${DEV_CONTAINER_NAME}" || true
        echo "Connected."
      fi
    else
      echo "No running devcontainer found yet (image 'vsc-*')."
      echo "After VS Code rebuilds the container, run:"
      echo "  docker network connect ${COMPOSE_NET} <DEV_CONTAINER_NAME>"
      echo "Find it with:"
      echo "  docker ps --format \"table {{.Names}}\\t{{.Image}}\" | grep \"\\tvsc-\""
    fi
  else
    echo "Compose network '${COMPOSE_NET}' not found."
    echo "Once your compose stack is up, connect the dev container with:"
    echo "  docker network connect ${COMPOSE_NET} <DEV_CONTAINER_NAME>"
  fi
else
  echo "Docker CLI not found. Skipping network auto-fix."
fi

echo ""
echo "Now do this in VS Code:"
echo "  F1 → Dev Containers: Rebuild and Reopen in Container"
echo ""
echo "Then verify inside the container terminal:"
echo "  python -c \"import socket; s=socket.socket(); s.settimeout(2); s.connect(('db',3306)); print('OK db:3306')\""
echo "  export DATABASE_URL=\"mysql+pymysql://root:\${DB_PASSWORD}@db:3306/\${DB_NAME}\""
echo "  flask run --host=0.0.0.0 --port=4000"
echo ""

git show -s --oneline --decorate HEAD
