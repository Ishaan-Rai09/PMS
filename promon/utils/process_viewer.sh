#!/bin/bash
#
# ProcessViewer module - For viewing and displaying system processes
#

# Function to view all running processes
view_processes() {
    echo -e "\n=== RUNNING PROCESSES ==="
    
    # Print header
    printf "%-8s %-12s %-8s %-8s %-15s %s\n" "PID" "USER" "CPU%" "MEM%" "NAME" "COMMAND"
    echo "--------------------------------------------------------------------------------"
    
    # Get process info and format it
    ps -eo pid,user,pcpu,pmem,comm,cmd --sort=-pcpu | head -n 50 | while read pid user cpu mem name cmd; do
        # Skip the header line
        if [[ "$pid" == "PID" ]]; then
            continue
        fi
        
        # Format CPU and MEM as float with 1 decimal place
        cpu=$(printf "%.1f" $cpu)
        mem=$(printf "%.1f" $mem)
        
        # Truncate command if too long
        if [ ${#cmd} -gt 60 ]; then
            cmd="${cmd:0:57}..."
        fi
        
        printf "%-8s %-12s %-8s %-8s %-15s %s\n" "$pid" "$user" "$cpu" "$mem" "$name" "$cmd"
    done
    
    # Count total processes
    total=$(ps -e | wc -l)
    echo "--------------------------------------------------------------------------------"
    echo "Total processes: $total (showing top 50 by CPU usage)"
}

# If this script is run directly, call the view_processes function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    view_processes
fi 