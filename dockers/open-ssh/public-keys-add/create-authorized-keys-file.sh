#!/bin/bash

function main {
    local user="$1"
    local authorized_keys_file="/home/$user/.ssh/authorized_keys"
    local current_perm

    # Case when user is root
    if [[ "$user" == "root" ]]; then
        authorized_keys_file="/root/.ssh/authorized_keys"
    fi

    if [[ ! -f "$authorized_keys_file" ]]; then

        touch "$authorized_keys_file"
        if [ $? -ne 0 ]; then
            echo "Cannot create $authorized_keys_file file" >&2
            exit 1
        fi

        chown "$user:$user" "$authorized_keys_file"
        if [ $? -ne 0 ]; then
            echo "Cannot change ownership of $authorized_keys_file file" >&2
            exit 1
        fi

    fi

    current_perm=$(stat -c "%a" "$authorized_keys_file")
    if [ $? -ne 0 ]; then
        echo "Cannot get permissions of $authorized_keys_file file" >&2
        exit 1
    fi

    if [ "$current_perm" -ne 600 ]; then
        chmod 600 "$authorized_keys_file"
        if [ $? -ne 0 ]; then
            echo "Cannot set permissions on $authorized_keys_file file" >&2
            exit 1
        fi
    fi

    exit 0
}