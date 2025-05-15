#!/bin/bash
#
# SafeKiller module - For identifying safe processes to kill and terminating processes
#

# List of critical process names that should never be killed
CRITICAL_PROCESSES=(
    "systemd" "init" "kthreadd" "kworker" "ksoftirqd" 
    "watchdog" "migration" "sshd" "bash" "sh" "zsh"
    "ps" "top" "python3" "python" "sudo" "su"
    "dbus" "NetworkManager" "wpa_supplicant" "dhclient"
    "cron" "rsyslogd" "systemd-journald" "systemd-udevd"
    "systemd-logind" "systemd-resolved" "systemd-timesyncd"
    "xorg" "Xorg" "gnome-shell" "gdm" "lightdm" "sddm"
    "upstart" "snapd" "dnsmasq" "avahi-daemon" "ModemManager"
    "polkit" "accounts-daemon" "thermald" "udisksd"
    "ntpd" "chronyd" "bluetoothd" "cupsd" "firewalld"
)

# Function to determine if a process is safe to kill
is_safe_to_kill() {
    local pid="$1"
    local proc_name=$(ps -p "$pid" -o comm= 2>/dev/null)
    local proc_user=$(ps -p "$pid" -o user= 2>/dev/null)
    local current_user=$(whoami)
    
    # Skip if process doesn't exist
    if [ -z "$proc_name" ]; then
        return 1
    fi
    
    # Skip processes not owned by the current user (unless root)
    if [ "$current_user" != "root" ] && [ "$proc_user" != "$current_user" ]; then
        return 1
    fi
    
    # Skip system processes (with low PIDs) unless root
    if [ "$pid" -lt 1000 ] && [ "$current_user" != "root" ]; then
        return 1
    fi
    
    # Skip any process name that matches a critical process
    for crit_proc in "${CRITICAL_PROCESSES[@]}"; do
        if [[ "$proc_name" == *"$crit_proc"* ]]; then
            return 1
        fi
    done
    
    # Skip kernel threads
    if [[ "$proc_name" =~ ^k.* ]] || [[ "$proc_name" =~ ^rcu.* ]] || [[ "$proc_name" =~ ^watchdog.* ]]; then
        return 1
    fi
    
    # Process is likely safe if we've passed all the checks
    return 0
}

# Function to show processes that are safe to kill
show_safe_processes() {
    echo -e "\n=== SAFE PROCESSES TO KILL ==="
    echo "These processes are likely safe to terminate:"
    echo
    
    # Print header
    printf "%-8s %-12s %-8s %-8s %-15s %s\n" "PID" "USER" "CPU%" "MEM%" "NAME" "COMMAND"
    echo "--------------------------------------------------------------------------------"
    
    # Get process info and check if it's safe to kill
    ps -eo pid,user,pcpu,pmem,comm,cmd --sort=-pcpu | head -n 200 | while read pid user cpu mem name cmd; do
        # Skip the header line
        if [[ "$pid" == "PID" ]]; then
            continue
        fi
        
        # Check if process is safe to kill
        if is_safe_to_kill "$pid"; then
            # Format CPU and MEM as float with 1 decimal place
            cpu=$(printf "%.1f" $cpu)
            mem=$(printf "%.1f" $mem)
            
            # Truncate command if too long
            if [ ${#cmd} -gt 60 ]; then
                cmd="${cmd:0:57}..."
            fi
            
            printf "%-8s %-12s %-8s %-8s %-15s %s\n" "$pid" "$user" "$cpu" "$mem" "$name" "$cmd"
        fi
    done
    
    echo "--------------------------------------------------------------------------------"
    echo "WARNING: Always verify before killing any process!"
}

# Function to kill a process by PID
kill_process() {
    local pid="$1"
    
    # Check if process exists
    if ! ps -p "$pid" &>/dev/null; then
        echo "Error: Process with PID $pid does not exist."
        return 1
    fi
    
    # Try terminating the process gracefully first (SIGTERM)
    kill "$pid" 2>/dev/null
    
    # Wait for up to 3 seconds for the process to terminate
    for ((i=0; i<3; i++)); do
        if ! ps -p "$pid" &>/dev/null; then
            echo "Process with PID $pid has been terminated."
            return 0
        fi
        sleep 1
    done
    
    # If still alive, kill it forcefully (SIGKILL)
    if ps -p "$pid" &>/dev/null; then
        kill -9 "$pid" 2>/dev/null
        
        # Check if process was killed
        if ! ps -p "$pid" &>/dev/null; then
            echo "Process with PID $pid has been forcefully terminated."
            return 0
        else
            echo "Error: Permission denied when trying to kill process with PID $pid."
            echo "You may need to run this command with higher privileges (e.g., sudo)."
            return 1
        fi
    else
        echo "Process with PID $pid has been terminated."
        return 0
    fi
}

# If this script is run directly, call the show_safe_processes function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    show_safe_processes
fi 