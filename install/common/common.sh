#!/bin/bash
echo "RUNNING modules/template-module/install/common/common.sh"
export MODULE_ROOT="$ROOT/modules/template-module"

# --- CONFIGURATION ---
MODULE_NAME=$(basename "$MODULE_ROOT")   # infer module name from dir name
MODULE_CLASS="common"
MODULE_ID=$MODULE_NAME-$MODULE_CLASS
DOCKERFILE_PATH="$MODULE_ROOT/docker/$MODULE_CLASS/Dockerfile"
SERVICE_SRC="$MODULE_ROOT/install/common/$MODULE_ID.service"
SERVICE_DST="/etc/systemd/system/$MODULE_ID.service"
IMAGE_NAME="$MODULE_ID:latest"

# # --- BUILD IMAGE ---
echo "Building Docker image: $IMAGE_NAME"
docker build -t "$IMAGE_NAME" -f "$DOCKERFILE_PATH" "$MODULE_ROOT/docker/common"

# # --- INSTALL SYSTEMD SERVICE ---
echo "Installing systemd service: $SERVICE_DST"
sudo cp "$SERVICE_SRC" "$SERVICE_DST"
sudo chmod 644 "$SERVICE_DST"

# # Reload systemd to pick up new/changed service file
echo "Reloading systemd daemon"
sudo systemctl daemon-reload

# # --- ENABLE & START SERVICE ---
echo "Enabling $MODULE_ID.service"
sudo systemctl enable "$MODULE_ID.service"

echo "Starting $MODULE_ID.service"
sudo systemctl restart "$MODULE_ID.service"

echo "Deployment complete for module: $MODULE_ID"

