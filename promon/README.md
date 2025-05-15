# ProMon - A Lightweight Linux Process Management & Monitoring Tool (Bash Version)

ProMon is a terminal-based Linux tool that allows users to view, monitor, and manage system processes safely and effectively. It provides intelligent suggestions for safe process termination, tracks system usage, maintains logs, and educates users about the tool's functionality.

This version is implemented entirely in Bash shell scripts and uses native Linux commands, so it doesn't require Python or any additional dependencies.

## Features

- **View Processes**: Display all running processes with details like PID, USER, CPU%, MEM%, and command.
- **Show Safe Processes to Kill**: Intelligently identify and suggest non-critical processes that are safe to terminate.
- **Kill Process by PID**: Safely terminate processes with confirmation steps and status messages.
- **View System Usage**: Monitor CPU, memory, disk, and network usage.
- **View Logs**: See a history of actions performed within the tool.
- **About**: Learn about the tool's functionality and safe process management.

## Installation

### Requirements

- Linux system with Bash shell
- Standard Linux utilities: ps, top, kill, df, etc.

### Setup

1. Clone the repository:
   ```
   https://github.com/Ishaan-Rai09/PMS.git
   cd promon
   ```

2. Make the main script executable:
   ```
   chmod +x promonsh
   chmod +x utils/*.sh
   ```

## Usage

Run the tool with:

```
./promonsh
```

### Command-line Options

- `--about`: Display information about ProMon

## Safety Notes

- Be careful when terminating processes. Killing system-critical processes can lead to system instability.
- ProMon attempts to identify "safe" processes to kill, but always verify before terminating any process.
- The tool is designed to be safe, but use at your own risk.

## Project Structure

```
promon/
├── promonsh             # Main script
├── utils/               # Utility modules
│   ├── process_viewer.sh # Process viewing functionality
│   ├── safe_killer.sh    # Safe process killing functionality
│   ├── system_monitor.sh # System monitoring functionality
│   └── logger.sh         # Logging functionality
├── logs/                 # Log directory
│   └── promon.log        # Log file
└── README.md             # This file
```

## Compatibility

This tool is specifically designed for Linux systems and uses Linux-specific features for process management and system monitoring. It should work on most Linux distributions including Ubuntu, Debian, CentOS, Fedora, and others.

## License

This project is open source, under the MIT License. 
