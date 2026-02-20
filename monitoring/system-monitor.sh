#!/bin/bash

# ============================================
# Script Name: system-monitor.sh
# Description: Basic shell script to monitor system resources
# Author: Dan Fenton
# Date: 17-02-2026
# Version: 1.1
# ============================================

# --- Source .env ---
# Get the real path from the sym link
REAL_PATH=$(realpath /usr/local/bin/system-monitor)
SCRIPT_DIR=$(dirname "$REAL_PATH")
# Source .env file
source $SCRIPT_DIR/.env

# --- Variables ---
TIMESTAMP=$(date)

# --- Functions ---

# Display header
# ----------------
display_header() {
    echo -e "====================================================="
    echo -e "System Monitor Script - $TIMESTAMP"
    echo -e "====================================================="
    echo -e "\nHello, $USER!"
    echo -e "\nI am just running some system monitoring checks..."
}

# Check memory values
# --------------------
check_memory() {
    local total_mem=$(free -m | grep Mem: | awk '{print $2}')
    local used_mem=$(free -m | grep Mem: | awk '{print $3}')
    local percentage_used=$((used_mem * 100 / total_mem))        # Convert to percentage value
    echo -e "\nMemory:\n-------------\nThe current memory usage is $percentage_used%"
}

# Get CPU usage
# --------------
check_cpu() {
    local cpu_usage=$(ps aux | awk 'NR>1 {print $2, $3, $11}' | sort -k2 -rn | head -5)
    echo -e "\nCPU:\n-------------\nHere are the top 5 processes by CPU % used..."
    echo "---------------------------"
    echo "PID  |  %CPU  | COMMAND"
    echo "---------------------------"
    echo "$cpu_usage"
    # Advice on CPU management
    echo -e "\nNote: If you want to kill any of these processes, you can run the following command:"
    echo "sudo kill -9 <PID>"
}

# Check disk usage
# -----------------
check_disk() {
    local disk_usage=$(df -h | sort -k5 -n)
    echo -e "\nDisk usage:\n--------------"
    echo "$disk_usage"
}

# Check uptime
# -------------
check_uptime() {
    local server_uptime=$(uptime -p)
    echo -e "\nUptime:\n-------------\nThe server has been up for: $server_uptime"
}

# --- Main ---

# Header
# --------
display_header | tee -a "$LOG_FILE"

# Memory usage
# -------------
check_memory | tee -a "$LOG_FILE"

# CPU usage
# ----------
check_cpu | tee -a "$LOG_FILE"

# Disk usage
# ------------
check_disk | tee -a "$LOG_FILE"

# Server uptime
# --------------
check_uptime | tee -a "$LOG_FILE"
 