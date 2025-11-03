#!/bin/bash

function main {
    local current_dir
    local file_path
    local output

    current_dir="$(dirname "$BASH_SOURCE[0]")"
    if [ $? -ne 0 ]; then
        echo "Failed to determine current directory: $current_dir" >&2
        exit 1
    fi

    file_path="$current_dir/sshd-actions.lock"

    output=$(flock -x "$file_path" -c "
        bash -c '
            source \"$current_dir/stop.sh\" && mainWithoutFlock
            exit \$?
        '"
    )
    if [ $? -ne 0 ]; then
        throw "Failed to execute mainWithoutFlock: $output" >&2
        exit 1
    fi

    exit 0

}


function mainWithoutFlock {
    local pid_number

    pid_number=$(pgrep -x "sshd")
    if [ -n "$pid_number" ]; then
        kill "$pid_number"
        while true; do
            if ! ps -p "$pid_number" > /dev/null 2>&1; then
                break
            else
                sleep 0.1
            fi
        done
    fi

    exit 0

}