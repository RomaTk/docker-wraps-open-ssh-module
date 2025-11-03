#!/bin/bash

function main {
    local user="$1"
    local index="$2"

    local file_path="/home/$user/.ssh/authorized_keys"

    if  [[ "$user" == "root" ]]; then
        file_path="/root/.ssh/authorized_keys"
    fi

    cat ./keys/$index.pub >> "$file_path"
    if [ $? -ne 0 ]; then
        echo "Cannot append public key to $file_path file" >&2
        exit 1
    fi

    exit 0
}