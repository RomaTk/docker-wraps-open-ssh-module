#!/bin/bash

function main {
    local user="$1"
    local current_perm

    local directory_path="/home/$user/.ssh"

    if [[ "$user" == "root" ]]; then
        directory_path="/root/.ssh"
    fi

    if [[ ! -d "$directory_path" ]]; then

        mkdir -p "$directory_path"
        if [ $? -ne 0 ]; then
            echo "Cannot create $directory_path directory" >&2
            exit 1
        fi

        chown "$user:$user" "$directory_path"
        if [ $? -ne 0 ]; then
            echo "Cannot change ownership of $directory_path directory" >&2
            exit 1
        fi

    fi

    current_perm=$(stat -c "%a" "$directory_path")
    if [ $? -ne 0 ]; then
        echo "Cannot get permissions of $directory_path directory" >&2
        exit 1
    fi

    if [ "$current_perm" -ne 700 ]; then
        chmod 700 "$directory_path"
        if [ $? -ne 0 ]; then
            echo "Cannot set permissions on $directory_path directory" >&2
            exit 1
        fi
    fi

    exit 0
}