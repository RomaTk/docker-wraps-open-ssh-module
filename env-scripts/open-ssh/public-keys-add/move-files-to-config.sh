#!/bin/bash

function main {
    local keys_folder="$1"
    local path_to_docker="$2"
    local path_to_exact_folder_in_context="public-keys-add/keys"
    local file_config="keys-configuration.json"

    local array
    local array_length
    local i
    local index

    local last_action

    if [ -z "$path_to_docker" ]; then
        echo "Path to docker is not set" >&2
        exit 1
    fi

    (
        current_dir="$(dirname "$BASH_SOURCE[0]")"
        source "$current_dir/clean.sh"
        if [ $? -ne 0 ]; then
            echo "Failed to source clean.sh" >&2
            exit 1
        fi

        main "$path_to_docker"
    )
    if [ $? -ne 0 ]; then
        echo "Failed within clean.sh script" >&2
        exit 1
    fi

    if [ -z "$keys_folder" ]; then
        exit 0
    fi

    if [ ! -f "$keys_folder/$file_config" ]; then
        exit 0
    fi

    last_action=$(cp -f "$keys_folder/$file_config" "$path_to_docker/$path_to_exact_folder_in_context/$file_config")
    if [ $? -ne 0 ]; then
        echo "Failed to copy $file_config: $last_action" >&2
        exit 1
    fi

    array=$(cat "$keys_folder/$file_config")
    if [ $? -ne 0 ]; then
        echo "Failed to read $file_config: $array" >&2
        exit 1
    fi

    array_length=$(echo "$array" | jq -r '. | length')
    if [ $? -ne 0 ]; then
        echo "Failed to get array length from $file_config: $array_length" >&2
        exit 1
    fi

    for ((i=0; i<array_length; i++)); do
        
        index=$(echo "$array" | jq -r ".[$i].index")
        if [ $? -ne 0 ]; then
            echo "Failed to get index for element $i from $file_config: $index" >&2
            exit 1
        fi

        last_action=$(cp -f "$keys_folder/$index.pub" "$path_to_docker/$path_to_exact_folder_in_context/$index.pub")
        if [ $? -ne 0 ]; then
            echo "Failed to copy $index.pub: $last_action" >&2
            exit 1
        fi
        
    done

    exit 0
}