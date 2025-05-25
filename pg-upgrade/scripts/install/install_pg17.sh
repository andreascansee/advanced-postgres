#!/bin/bash

set -e  # Exit on error

echo "==> Ensuring required tools are installed..."
sudo apt update
sudo apt install -y curl gnupg2 lsb-release ca-certificates

echo "==> Adding PostgreSQL APT repository for version 17..."
CODENAME=$(lsb_release -cs)
echo "Using distribution codename: $CODENAME"
echo "deb http://apt.postgresql.org/pub/repos/apt ${CODENAME}-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list

echo "==> Importing PostgreSQL signing key..."
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg

echo "==> Updating package lists (again)..."
sudo apt update

echo "==> Installing PostgreSQL 17..."
sudo apt install -y postgresql-17

echo "✅ PostgreSQL 17 installation complete!"