#!/bin/bash
set -euo pipefail

# Resolve config location relative to this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../vm.conf"

# Load VM configuration
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
else
  echo "❌ ERROR: Config file not found: $CONFIG_FILE"
  exit 1
fi

echo "🛑 Stopping VM: $VM_NAME..."
multipass stop "$VM_NAME" || echo "⚠️  VM already stopped or does not exist."

echo "🗑️  Deleting VM: $VM_NAME..."
multipass delete "$VM_NAME" || echo "⚠️  VM already deleted or does not exist."

echo "🧹 Purging unused data (snapshots, volumes)..."
multipass purge

echo "✅ VM '$VM_NAME' and related data removed."