#!/bin/bash
#
# SystemMonitor module - For monitoring system resource usage
#

# Function to format bytes into human-readable format
format_size() {
    local bytes="$1"
    local unit="B"
    
    if [ "$bytes" -gt 1024 ]; then
        bytes=$((bytes / 1024))
        unit="KB"
    fi
    
    if [ "$bytes" -gt 1024 ]; then
        bytes=$((bytes / 1024))
        unit="MB"
    fi
    
    if [ "$bytes" -gt 1024 ]; then
        bytes=$((bytes / 1024))
        unit="GB"
    fi
    
    if [ "$bytes" -gt 1024 ]; then
        bytes=$((bytes / 1024))
        unit="TB"
    fi
    
    echo "$bytes $unit"
}

# Function to show system usage information
show_system_usage() {
    # ===================
    # System Information
    # ===================
    echo -e "\n=== SYSTEM INFORMATION ==="
    echo "System: $(uname -s)"
    echo "Node: $(uname -n)"
    echo "Release: $(uname -r)"
    echo "Version: $(uname -v)"
    echo "Machine: $(uname -m)"
    echo "Processor: $(uname -p)"
    # Get uptime
    uptime_output=$(uptime)
    echo "Uptime: $uptime_output"
    
    # ===================
    # CPU Usage
    # ===================
    echo -e "\n=== CPU USAGE ==="
    # Get CPU info
    if [ -f /proc/cpuinfo ]; then
        physical_cores=$(grep "physical id" /proc/cpuinfo | sort -u | wc -l)
        total_cores=$(grep -c "processor" /proc/cpuinfo)
        echo "Physical cores: $physical_cores"
        echo "Total cores: $total_cores"
    else
        echo "CPU info not available"
    fi
    
    # Get CPU usage percentage
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    echo "Total CPU usage: ${cpu_usage}%"
    
    # Get per-core usage if available
    if command -v mpstat &>/dev/null; then
        echo "Per-core CPU usage:"
        mpstat -P ALL 1 1 | grep -A 100 "%user" | grep -v "%user" | grep -v "^$" | awk '{print "Core " $2 ": " $3 + $5 "%"}'
    fi
    
    # ===================
    # Memory Usage
    # ===================
    echo -e "\n=== MEMORY USAGE ==="
    if [ -f /proc/meminfo ]; then
        # Get memory info
        total_mem=$(grep "MemTotal" /proc/meminfo | awk '{print $2}')
        free_mem=$(grep "MemFree" /proc/meminfo | awk '{print $2}')
        available_mem=$(grep "MemAvailable" /proc/meminfo | awk '{print $2}')
        used_mem=$((total_mem - available_mem))
        mem_percent=$(awk "BEGIN {printf \"%.1f\", ($used_mem/$total_mem)*100}")
        
        echo "Total: $(format_size $((total_mem * 1024)))"
        echo "Available: $(format_size $((available_mem * 1024)))"
        echo "Used: $(format_size $((used_mem * 1024)))"
        echo "Usage: ${mem_percent}%"
    else
        # Fallback to free command
        echo "Memory info (from free command):"
        free -h
    fi
    
    # ===================
    # Disk Usage
    # ===================
    echo -e "\n=== DISK USAGE ==="
    df -h | grep -v "tmpfs" | grep -v "udev"
    
    # ===================
    # Network I/O
    # ===================
    echo -e "\n=== NETWORK I/O ==="
    if [ -f /proc/net/dev ]; then
        # Skip the first two lines (headers)
        network_stats=$(cat /proc/net/dev | tail -n +3)
        
        # Get total RX/TX
        total_rx=0
        total_tx=0
        
        echo "$network_stats" | while read line; do
            # Extract interface name
            interface=$(echo "$line" | awk -F: '{print $1}' | tr -d ' ')
            # Extract RX/TX bytes
            rx_bytes=$(echo "$line" | awk '{print $2}')
            tx_bytes=$(echo "$line" | awk '{print $10}')
            
            # Skip loopback interface and interfaces with no traffic
            if [[ "$interface" != "lo" && ("$rx_bytes" != "0" || "$tx_bytes" != "0") ]]; then
                # Calculate total
                total_rx=$((total_rx + rx_bytes))
                total_tx=$((total_tx + tx_bytes))
                
                echo "Interface: $interface"
                echo "  Received: $(format_size $rx_bytes)"
                echo "  Transmitted: $(format_size $tx_bytes)"
            fi
        done
    else
        # Fallback to ifconfig command
        echo "Network info not available from /proc/net/dev"
        if command -v ifconfig &>/dev/null; then
            ifconfig | grep -E "RX|TX"
        elif command -v ip &>/dev/null; then
            ip -s link
        fi
    fi
}

# If this script is run directly, call the show_system_usage function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    show_system_usage
fi 