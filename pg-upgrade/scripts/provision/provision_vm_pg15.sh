#!/bin/bash
set -euo pipefail

# Resolve paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../vm.conf"
INSTALL_SCRIPT_BASENAME="install_pg15.sh"
INSTALL_SCRIPT="$SCRIPT_DIR/../install/$INSTALL_SCRIPT_BASENAME"

# Load VM configuration
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
else
  echo "❌ ERROR: Config file not found: $CONFIG_FILE"
  exit 1
fi

echo "==> Launching Multipass VM: $VM_NAME..."
multipass launch \
  --name "$VM_NAME" \
  --cpus "$VM_CPUS" \
  --memory "$VM_MEMORY" \
  --disk "$VM_DISK"

echo "==> Transferring PostgreSQL 15 install script..."
if [[ ! -f "$INSTALL_SCRIPT" ]]; then
  echo "❌ ERROR: Install script not found: $INSTALL_SCRIPT"
  exit 1
fi

(cd "$(dirname "$INSTALL_SCRIPT")" && multipass transfer "$INSTALL_SCRIPT_BASENAME" "$VM_NAME":/home/ubuntu)

echo "==> Installing PostgreSQL 15 inside VM..."
multipass exec "$VM_NAME" -- bash "/home/ubuntu/$INSTALL_SCRIPT_BASENAME"

echo "✅ VM '$VM_NAME' is ready with PostgreSQL 15."