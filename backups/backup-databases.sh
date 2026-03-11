#!/bin/bash

# ========================================================
# Script Name: backup-databases.sh
# Description: Backup PostgreSQL databases using pg_dump
# Author: Dan Fenton
# Date: 2026-03-11
# Version: 1.0
# ========================================================

# --- Source .env ---
REAL_PATH=$(realpath "$0")
SCRIPT_DIR=$(dirname "$REAL_PATH")
source $SCRIPT_DIR/.env

# --- Variables ---
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR=$DEST_DIR/databases/$TIMESTAMP
LOG_FILE="$LOG_FILE.db-backup"
CONTAINER_NAME="postgres"
DB_USER="${DB_USER:-webui_user}"
DB_PASSWORD="${DB_PASSWORD:-}"

# --- Functions ---

header() {
    echo -e "\n=========================\nDATABASE BACKUP STARTING\n========================" | tee -a "$LOG_FILE"
    echo "Timestamp: $TIMESTAMP" | tee -a "$LOG_FILE"
}

check_container() {
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo "Container '$CONTAINER_NAME' is running." | tee -a "$LOG_FILE"
        return 0
    else
        echo "ERROR: Container '$CONTAINER_NAME' is not running." | tee -a "$LOG_FILE"
        exit 1
    fi
}

create_backup_dir() {
    mkdir -p "$BACKUP_DIR"
    if [ $? -eq 0 ]; then
        echo "Backup directory created: $BACKUP_DIR" | tee -a "$LOG_FILE"
    else
        echo "ERROR: Could not create backup directory." | tee -a "$LOG_FILE"
        exit 1
    fi
}

list_databases() {
    # Get list of databases (excluding template and system databases)
    docker exec -e PGPASSWORD="$DB_PASSWORD" "$CONTAINER_NAME" psql \
        -h "$DB_HOST" \
        -U "$DB_USER" \
        -d "$DEFAULT_DB" \
        -t -c "SELECT datname FROM pg_database WHERE datistemplate = false AND datname NOT IN ('postgres');" | tr -d ' \r'
}

backup_database() {
    local dbname=$1

    echo "Backing up database: $dbname" | tee -a "$LOG_FILE"

    # Create SQL dump (plain format with verbose output)
    docker exec -e PGPASSWORD="$DB_PASSWORD" "$CONTAINER_NAME" \
        pg_dump -h "$DB_HOST" \
        -U "$DB_USER" \
        --format=plain \
        --verbose \
        "$dbname" > "$BACKUP_DIR/${dbname}.sql" 2>&1

    # Check if the backup file was created and has content
    if [ -s "$BACKUP_DIR/${dbname}.sql" ]; then
        local size=$(du -h "$BACKUP_DIR/${dbname}.sql" | cut -f1)
        echo "SUCCESS: $dbname backed up ($size)" | tee -a "$LOG_FILE"

        # Also create compressed version
        gzip -k "$BACKUP_DIR/${dbname}.sql"
        echo "Compressed backup created: ${dbname}.sql.gz" | tee -a "$LOG_FILE"
    else
        echo "ERROR: Failed to backup $dbname - no output file created" | tee -a "$LOG_FILE"
        return 1
    fi
}

backup_all() {
    local failed=0

    for dbname in $(list_databases); do
        if [ -n "$dbname" ]; then
            backup_database "$dbname" || ((failed++))
        fi
    done

    echo "" | tee -a "$LOG_FILE"
    if [ $failed -eq 0 ]; then
        echo "All databases backed up successfully!" | tee -a "$LOG_FILE"
    else
        echo "Completed with $failed failure(s)" | tee -a "$LOG_FILE"
    fi

    return $failed
}

cleanup_old_backups() {
    local keep_days=${KEEP_DAYS:-30}

    echo "" | tee -a "$LOG_FILE"
    echo "Cleaning up backups older than $keep_days days..." | tee -a "$LOG_FILE"

    # Find and remove old backup directories
    find "$DEST_DIR/databases" -type d -mtime +$keep_days -exec rm -rf {} + 2>/dev/null

    echo "Cleanup complete." | tee -a "$LOG_FILE"
}

# --- Main ---

header
check_container
create_backup_dir
backup_all
cleanup_old_backups

echo ""
echo "Backup location: $BACKUP_DIR" | tee -a "$LOG_FILE"
