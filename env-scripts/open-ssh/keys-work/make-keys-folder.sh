#!/bin/bash

function main {
    local secrets_folder="$1"
    local path_to_keys="$2"
    local folder="${secrets_folder}/${path_to_keys}"
    if [ ! -d "$folder" ]; then
        mkdir -p "$folder"
        [ $? -ne 0 ] && exit 1
    fi

    if [[ ! -f "$folder/keys-configuration.json" ]]; then
        echo "[]" > "$folder/keys-configuration.json"
        [ $? -ne 0 ] && exit 1
    fi

    if [[ ! -f "$folder/keys-passphrases.json" ]]; then
        echo "{}" > "$folder/keys-passphrases.json"
        [ $? -ne 0 ] && exit 1
    fi

    exit 0
}