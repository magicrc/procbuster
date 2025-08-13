#!/bin/bash

print_usage() {
    cat <<EOF
Lists processes by brute-forcing /proc PIDs and reading status and cmdline.

Usage: $0 [--file-read-cmd CMD] [--max-pid MAX_PID] [--help]

Options:
  --file-read-cmd CMD    Command used to read files, e.g. curl piped with sed stored in dedicated script / binary (default: cat)
  --max-pid MAX_PID      Maximum PID to check (default: 65535)
  -h, --help             Show this help message
EOF
}

# Defaults
file_read_cmd="cat"
max_pid=65535

while [[ $# -gt 0 ]]; do
    case "$1" in
        --file-read-cmd)
            file_read_cmd="$2"
            shift 2
            ;;
        --max-pid)
            max_pid="$2"
            shift 2
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            print_usage
            exit 1
            ;;
    esac
done

# Read users from /etc/passwd
declare -A users_map
while IFS=: read -r user _ uid _ _ _ _; do
    users_map["$uid"]="$user"
done < <("${file_read_cmd[@]}" /etc/passwd 2>/dev/null)

# Print header
printf "%-7s %-20s %s\n" "PID" "USER" "CMD"

# Loop over PIDs
for pid in $(seq 1 "$max_pid"); do
    status="$("${file_read_cmd[@]}" "/proc/$pid/status" 2>/dev/null)"
    if [ -n "$status" ]; then
        uid=$(echo "$status" | awk '/^Uid:/ {print $2}')
        username="${users_map[$uid]:-UNKNOWN}"
        cmdline="$("${file_read_cmd[@]}" "/proc/$pid/cmdline" 2>/dev/null | tr '\0' ' ')"
        if [ -z "$cmdline" ]; then
            cmdline="[$("${file_read_cmd[@]}" "/proc/$pid/comm" 2>/dev/null)]"
        fi
        printf "%-7s %-20s %s\n" "$pid" "$username" "$cmdline"
    fi
done
