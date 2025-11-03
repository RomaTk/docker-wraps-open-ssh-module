#!/bin/bash

function main {
    local key_name
    local host
    local additional_options
    local port_number
    local command_in_ssh

    local current_file
    local current_dir

    current_file="${BASH_SOURCE[0]}"
    current_dir="$(dirname "$current_file")"
    [ $? -ne 0 ] && exit 1

    echo "Please select the key name"
    read key_name
    echo "Please select the host to connect to"
    read host
    echo "Please enter the port number to connect to (leave empty for default port 22):"
    read port_number
    echo "Please enter the additional SSH options (space-separated), or leave empty for none:"
    read additional_options
    echo "If there is a command to run on the remote host after connecting, please enter it now (or leave empty for none):"
    read command_in_ssh

    source "$current_dir/config.cfg"
    [ $? -ne 0 ] && exit 1

    if [ -z "$BASIC_DIR" ]; then
        echo "Error: BASIC_DIR is not set in config.cfg"
        exit 1
    fi

    (source "$BASIC_DIR/connect.sh" && main "$key_name" "$host" "$port_number" "$additional_options" "$command_in_ssh" "true")
    if [ $? -ne 0 ]; then
        echo "Error: Failed to execute basic connect script"
        exit 1
    fi

    exit 0
}