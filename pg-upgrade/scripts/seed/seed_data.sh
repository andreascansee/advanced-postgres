#!/bin/bash
set -euo pipefail

# --- Configuration ---
DB_NAME="appdb"

# --- Resolve local paths ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../vm.conf"
DATA_DIR="$SCRIPT_DIR/../../data"
REMOTE_PARENT_DIR="/var/tmp"
REMOTE_DATA_DIR="$REMOTE_PARENT_DIR/data"

# --- Load config ---
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
else
  echo "❌ ERROR: Config file not found: $CONFIG_FILE"
  exit 1
fi

echo "==> Cleaning remote target directory $REMOTE_DATA_DIR on VM '$VM_NAME'..."
multipass exec "$VM_NAME" -- sudo rm -rf "$REMOTE_DATA_DIR"

echo "==> Transferring local 'data/' directory to $REMOTE_PARENT_DIR on VM '$VM_NAME'..."
multipass transfer --recursive "$DATA_DIR" "$VM_NAME":"$REMOTE_PARENT_DIR"

echo "==> Executing SQL scripts in VM '$VM_NAME'..."
for SQL_FILE in "$DATA_DIR"/*.sql; do
  FILENAME=$(basename "$SQL_FILE")
  echo ""
  echo "╭─ Executing SQL: $FILENAME"

  # We must run 00_init_db.sql against the 'postgres' database,
  # because it drops and recreates the target database ($DB_NAME).
  # You cannot drop the database you're currently connected to.
  # All other scripts run against the newly created $DB_NAME.
  if [[ "$FILENAME" == "00_init_db.sql" ]]; then
    multipass exec "$VM_NAME" -- bash -c "cd /var/tmp && sudo -u postgres psql -d postgres -f '$REMOTE_DATA_DIR/$FILENAME'"
  else
    multipass exec "$VM_NAME" -- bash -c "cd /var/tmp && sudo -u postgres psql -d $DB_NAME -f '$REMOTE_DATA_DIR/$FILENAME'"
  fi
done

echo "✅ All SQL scripts executed successfully on VM '$VM_NAME'"
