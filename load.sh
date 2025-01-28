#!/bin/bash

# Get the current date and time
date=$(date +"%Y-%m-%d %H:%M:%S")

# Get the current CPU usage
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | awk -F. '{print $1}')

# Get the current memory usage
mem_usage=$(free -m | awk 'NR==2{printf "%s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }')
# Get the current disk usage
disk_usage=$(df -h | grep sda3 | awk '{print $5}')

net=$(python ~/bin/get_net.py)

# Output the information in a format that can be displayed in the Tmux status bar
echo -n "$date | $cpu_usage% | $mem_usage | $net | $disk_usage | $(hostname)"
