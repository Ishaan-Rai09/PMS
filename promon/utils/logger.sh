#!/bin/bash
#
# Logger module - For logging user actions
#

# Get script directory
SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
LOG_DIR="$(dirname "$SCRIPT_DIR")/logs"
LOG_FILE="$LOG_DIR/promon.log"

# Function to show logs
show_logs() {
    local n=50
    
    # Create log directory if it doesn't exist
    mkdir -p "$LOG_DIR"
    
    # Create log file if it doesn't exist
    touch "$LOG_FILE"
    
    # Show logs
    echo -e "\n=== LOGS ==="
    
    # Check if log file is empty
    if [ ! -s "$LOG_FILE" ]; then
        echo "No log entries found."
        return
    fi
    
    # Count total lines in log file
    total_lines=$(wc -l < "$LOG_FILE")
    
    # If less than n lines, show all
    if [ "$total_lines" -le "$n" ]; then
        echo "All log entries:"
        cat "$LOG_FILE"
    else
        # Show the most recent n lines
        echo "Most recent $n entries:"
        tail -n "$n" "$LOG_FILE"
    fi
    
    echo "---------------------------------------------------------"
}

# If this script is run directly, call the show_logs function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    show_logs
fi 