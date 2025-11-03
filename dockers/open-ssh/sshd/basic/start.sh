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
            source \"$current_dir/start.sh\" && mainWithoutFlock
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
    local global_path_to_sshd
    local port_number
    local pid_number

    pid_number=$(pgrep -x sshd)
    if [ $? -eq 0 ]; then
        exit 0
    fi

    global_path_to_sshd="$(whereis sshd)"
    if [ $? -ne 0 ]; then
        echo "Failed to locate sshd: $global_path_to_sshd" >&2
        exit 1
    fi

    global_path_to_sshd="$(echo "$global_path_to_sshd" | sed 's/^sshd: //')"
    if [ $? -ne 0 ]; then
        echo "Failed to process sshd path: $global_path_to_sshd" >&2
        exit 1
    fi

    ("$global_path_to_sshd")
    if [ $? -ne 0 ]; then
        echo "Failed to start sshd (command: '$global_path_to_sshd')" >&2
        exit 1
    fi

    while true; do

        pid_number=$(pgrep -x sshd)
        if [ $? -ne 0 ]; then
            echo "Failed to get sshd process ID: $pid_number" >&2
            exit 1
        fi

        port_number=$(ss -tulpn | grep "users:((\"sshd\",pid=$pid_number")
        if [ $? -eq 0 ]; then
            break
        fi

        sleep 0.1

    done

    exit 0

}