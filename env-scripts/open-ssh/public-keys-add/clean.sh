#!/bin/bash

function main {
    local path_to_docker="$1"
    local path_to_exact_folder_in_context="public-keys-add/keys"

    local last_action

    if [ -z "$path_to_docker" ]; then
        echo "Path to docker is not set" >&2
        exit 1
    fi

    last_action=$(cleanFolder "$path_to_docker/$path_to_exact_folder_in_context")
    if [ $? -ne 0 ]; then
        echo "Failed within cleanFolder function: $last_action" >&2
        exit 1
    fi

    exit 0
}

function cleanFolder {
    local target_dir="$1"
    local current_dir="$(pwd)"

    cd "$target_dir"
    [ $? -ne 0 ] && exit 1

    for item in * .*; do
        # The glob pattern '.*' matches '.', '..', and '.gitkeep'. We must skip them.
        if [[ "$item" == "." || "$item" == ".." || "$item" == ".gitkeep" ]]; then
        continue # Skip to the next item in the loop.
        fi

        # Remove the item recursively and forcefully.
        rm -rf "$item"
        [ $? -ne 0 ] && exit 1
    done

    cd "$current_dir"
    [ $? -ne 0 ] && exit 1

    exit 0
}