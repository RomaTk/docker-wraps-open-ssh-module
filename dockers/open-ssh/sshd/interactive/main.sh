#!/bin/bash

function main {
    local current_file
    local current_dir
    
    current_file="${BASH_SOURCE[0]}"
    if [ -z "$current_file" ]; then
        echo "Error: Cannot determine the current script file." >&2
        exit 1
    fi
    current_dir="$(dirname "$current_file")"
    if [ -z "$current_dir" ]; then
        echo "Error: Cannot determine the current script directory." >&2
        exit 1
    fi


    source "${current_dir}/config.cfg"

    if [ -z "$BASIC_DIR" ]; then
        echo "Error: BASIC_DIR is not set in config.cfg." >&2
        exit 1
    fi

    (source "${BASIC_DIR}/start.sh" && main)
    if [ $? -ne 0 ]; then
        echo "Error: Failed to execute main from basic start.sh." >&2
        exit 1
    fi

    read -p "Press [Enter] to exit the SSHD interactive container..."

    (source "${BASIC_DIR}/stop.sh" && main)
    if [ $? -ne 0 ]; then
        echo "Error: Failed to execute main from basic stop.sh." >&2
        exit 1
    fi


    exit 0
}