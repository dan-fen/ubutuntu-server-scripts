#!/bin/bash

# ============================================
# Script Name: data-backup-archive.sh
# Description: Bash script to backup data directory.
# Author: Dan Fenton
# Date: 2026-03-14
# Version: 1.0
# ============================================

# --- Source .env ---
# Get the real path from the sym link
REAL_PATH=$(realpath /usr/local/bin/archive-data)
SCRIPT_DIR=$(dirname "$REAL_PATH")
# Source .env file
source "$SCRIPT_DIR/.env"

# --- Variables ---
TIMESTAMP=$(date)
SOURCE_DIR=/data
BACKUP_DIR=$DEST_DIR/data-archive/$(date +%Y-%m-%d)
EXCLUDE_FILE=$SCRIPT_DIR/exclude-list-data.txt

# --- Functions ---
header() {
    echo -e "\n==============================\nDATA ARCHIVE STARTING NOW\n==============================" | tee -a "$LOG_FILE"
    echo "Current timestamp: $TIMESTAMP" | tee -a "$LOG_FILE"
}

check_source() {
    if [ -d "$SOURCE_DIR" ]; then
        echo "$SOURCE_DIR is accessible" | tee -a "$LOG_FILE"
    else
        echo "$SOURCE_DIR is not accessible." | tee -a "$LOG_FILE"
        exit 1  # Failure
    fi
}

check_destination() {
    if [ -d "$DEST_DIR" ]; then
        echo "$DEST_DIR is accessible." | tee -a "$LOG_FILE"
    else
        echo "$DEST_DIR is not accessible." | tee -a "$LOG_FILE"
        exit 1
    fi
}

create_directory() {
    mkdir -p "$BACKUP_DIR"
    DIR_EXIT=$?
    if [ $DIR_EXIT == "0" ]; then
        echo "Backup directory created successfully." | tee -a "$LOG_FILE"
    else
        echo "Backup directory could not be created." | tee -a "$LOG_FILE"
        echo "Backup Failure: Exit code $DIR_EXIT" | tee -a "$LOG_FILE"
        exit 1  # Failure
    fi
}

archive_backup() {
    tar -cpf - --exclude-from="$EXCLUDE_FILE" -C "$SOURCE_DIR" . 2>> "$LOG_FILE" | gzip 2>> "$LOG_FILE" > "$BACKUP_DIR/data-backup-archive.tar.gz"
    PIPE_STATUS=("${PIPESTATUS[@]}")
    TAR_EXIT=${PIPE_STATUS[0]}
    GZIP_EXIT=${PIPE_STATUS[1]}
    if [ "$TAR_EXIT" -eq 0 ] && [ "$GZIP_EXIT" -eq 0 ]; then
        echo "Backup completed successfully!" | tee -a "$LOG_FILE"
    else
        echo "Backup failure: tar exit code $TAR_EXIT, gzip exit code $GZIP_EXIT" | tee -a "$LOG_FILE"
        exit 1  # Failure
    fi
    }

# --- Main ---

# Display Header
header

# Check that source directory is accessible
check_source

# Check that destination directory is accessible
check_destination

# Create time stamped backup directory
create_directory

# Run the archive backup 
archive_backup