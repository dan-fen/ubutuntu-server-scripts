#!/bin/bash

# ============================================
# Script Name: system-monitor.sh
# Description: Basic shell script to monitor system resources
# Author: Dan Fenton
# Date: 16-02-2026
# Version: 1.0
# ============================================

# --- Variables ---
LOG_FILE="/var/log/system_monitor.log"
TIMESTAMP=$(date)
SOURCE_DIR="/usr/local/bin"

# --- Functions ---

# Obtain memory values
total_mem=$(free -m | grep Mem: | awk '{print $2}')
used_mem=$(free -m | grep Mem: | awk '{print $3}')
percentage_used=$((used_mem * 100 / total_mem))

# --- Main ---
# Header
echo "Hello, $USER! Today's date is $TIMESTAMP."
echo "I am just running some system maintenance checks..."

# Memory usage
echo "The current memory usage is $percentage_used%"

# CPU usage
echo "Here are the top 5 processes by CPU % used..."
echo "PID    %CPU   COMMAND"
ps aux | awk 'NR>1 {print $2, $3, $11}' | sort -k2 -rn | head -5
# Advice on CPU management
echo "Note: If you want to kill any of these processes, you can run the following command:"
echo "sudo kill -9 <PID>"

# Disk usage
echo "Just checking disk usage for you now..."
df -h | sort -k4 -n

# Server uptime
echo "Finally, I'll just check the server uptime..."
uptime | awk {'print $1, $2, $3'} | tr -d ','
echo "Please consider rebooting the server if it has an uptime of more than a week."
