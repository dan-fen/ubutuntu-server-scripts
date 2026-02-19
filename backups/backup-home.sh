#!/bin/bash

# ============================================
# Script Name: backup-home.sh
# Description: Bash script to backup the home directory of a user.
# Author: Dan Fenton
# Date: 2026-02-19
# Version: 1.0
# ============================================

# --- Source .env ---
# Get the real path from the sym link
REAL_PATH=$(realpath /usr/local/bin/backup-home)
SCRIPT_DIR=$(dirname "$REAL_PATH")
# Source .env file
source $SCRIPT_DIR/.env

# --- Variables ---
TIMESTAMP=$(date)
SOURCE_DIR=/home/$USER/
BACKUP_DIR=$DEST_DIR/$(date +%Y-%m-%d)/
EXCLUDE_FILE=$SCRIPT_DIR/exclude-list.txt

# --- Functions ---
header() {
    echo -e "\n=========================\nHOME BACKUP STARTING NOW\n=========================" | tee -a "$LOG_FILE"
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
        echo "Backup Failure: Exit code $DIR_EXIT"
        exit 1  # Failure
    fi
}

rsync_backup() {
    rsync -a --info=progress2 --log-file="$LOG_FILE" --chown=:truenas --exclude-from="$EXCLUDE_FILE" "$SOURCE_DIR" "$BACKUP_DIR"
    RSYNC_EXIT=$?
    if [ $RSYNC_EXIT == "0" ]; then
        echo "Backup completed successfully!"
    else
        echo "Backup failure: Exit code $RSYNC_EXIT"
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

# Run the rsync backup 
rsync_backup
