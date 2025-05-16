#!/usr/bin/env bash
set -euo pipefail

# Load environment variables from .env
ENV_FILE=".env"
if [[ -f "$ENV_FILE" ]]; then
  export $(grep -v '^#' "$ENV_FILE" | xargs)
else
  echo "❌ .env file not found. Please create it from env.example."
  exit 1
fi

# Set defaults if vars aren't defined
ZPOOL="${ZPOOL}"                    # tank
DATASET_PATH="${NPM_DATASET_PATH}"  # docker/volumes/Nginx-Proxy-Manager
DATASET="${NPM_DATASET}"            # tank/docker/volumes/Nginx-Proxy-Manager

# Use zfs to verify and create dataset
if ! command -v zfs >/dev/null 2>&1; then
  echo "❌ zfs command not found. Is ZFS installed?"
  exit 1
fi

if ! zpool list -H -o name | grep -qx "$ZPOOL"; then
  echo "❌ ZFS pool '$ZPOOL' not found."
  exit 1
fi

if ! zfs list -H -o name "$DATASET" >/dev/null 2>&1; then
  echo "ℹ️ Creating ZFS dataset $DATASET"
  sudo zfs create -p \
  -o mountpoint="/$DATASET_PATH" \
  -o compression=zstd \
  -o atime=off \
  -o xattr=sa \
  -o acltype=posixacl \
  "$DATASET"
else
  echo "✅ ZFS dataset $DATASET already exists."
fi
