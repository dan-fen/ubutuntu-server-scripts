#!/bin/bash

# ============================================
# Script Name: home-backup.sh
# Description: Bash script to backup the home directory of my user account to Proton Drive.
# Author: Dan Fenton
# Date: 2026-04-05
# Version: 1.0
# ============================================

# =======================
#  HOME DIRECTORY BACKUP
# =======================

#!/bin/bash
set -euo pipefail
SCRIPT_DIR="/Users/$USER/Projects/bash-scripts/backups/rsync/mac"
ENV_FILE="$SCRIPT_DIR/.env"

if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
else
  echo "Missing .env file: $ENV_FILE"
  exit 1
fi

SOURCE_DIR="${SOURCE_DIR:-/Users/$USER/}"
DEST_DIR="${DEST_DIR:-/Volumes/Extended-Storage/Backups/$USER/}"
EXCLUDE_FILE="${EXCLUDE_FILE:-/Users/$USER/Scripts/Backups/exclude-list.txt}"

# Normalize source to ensure trailing slash for contents-only sync
SOURCE_DIR="${SOURCE_DIR%/}/"
DEST_DIR="${DEST_DIR%/}/"

echo "Source:      $SOURCE_DIR"
echo "Destination: $DEST_DIR"
echo "Exclude:     $EXCLUDE_FILE"

# Sanity checks
if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "Source directory does not exist: $SOURCE_DIR"
  exit 1
fi

if [[ ! -d "$(dirname "$DEST_DIR")" ]]; then
  echo "Parent destination directory does not exist: $(dirname "$DEST_DIR")"
  exit 1
fi

mkdir -p "$DEST_DIR"

if [[ ! -w "$DEST_DIR" ]]; then
  echo "Destination is not writable: $DEST_DIR"
  exit 1
fi

rsync -aEhv \
  --delete \
  --progress \
  --exclude-from="$EXCLUDE_FILE" \
  "$SOURCE_DIR" "$DEST_DIR"

echo "Backup complete."