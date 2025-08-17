#!/bin/bash
set -euo pipefail
echo "RUNNING modules/carplay-module/install/common/common.sh"

ROOT="${ROOT:-/opt/car-pi}"
MODULE_ROOT="$ROOT/modules/carplay-module"

MODULE_NAME=$(basename "$MODULE_ROOT")
MODULE_CLASS="common"
MODULE_ID="$MODULE_NAME-$MODULE_CLASS"

DOCKERFILE_PATH="$MODULE_ROOT/docker/$MODULE_CLASS/Dockerfile"
BUILD_CONTEXT="$MODULE_ROOT/docker/common"
SERVICE_SRC="$MODULE_ROOT/install/common/$MODULE_ID.service"
SERVICE_DST="/etc/systemd/system/$MODULE_ID.service"
IMAGE_NAME="$MODULE_ID:latest"

ENABLE_ON_BOOT=false
if [[ "${1:-}" == "--enable" ]]; then
  ENABLE_ON_BOOT=true
fi

echo "Building Docker image: $IMAGE_NAME"
docker build -t "$IMAGE_NAME" -f "$DOCKERFILE_PATH" "$BUILD_CONTEXT"

echo "Installing systemd service to $SERVICE_DST"
sudo cp "$SERVICE_SRC" "$SERVICE_DST"
sudo chmod 644 "$SERVICE_DST"

echo "Reloading systemd daemon"
sudo systemctl daemon-reload

echo "Starting $MODULE_ID.service"
sudo systemctl restart "$MODULE_ID.service"

if $ENABLE_ON_BOOT; then
  echo "Enabling $MODULE_ID.service at boot"
  sudo systemctl enable "$MODULE_ID.service"
else
  echo "NOT enabling at boot (pass --enable to enable later)"
fi

echo "Logs (Ctrl+C to exit):"
sudo journalctl -u "$MODULE_ID.service" -f
