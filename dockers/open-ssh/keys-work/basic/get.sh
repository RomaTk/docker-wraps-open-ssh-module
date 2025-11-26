#!/bin/bash

function main {
    local user="$1"
    local comment="$2"
    local config_file_path="$3"
    local output
    local current_file
    local current_dir

    if [[ -z "$user" ]]; then
        echo "User must not be empty" >&2
        exit 1
    fi

    current_file="${BASH_SOURCE[0]}"
    if [ -z "$current_file" ]; then
        echo "Cannot determine current file" >&2
        exit 1
    fi

    if [[ -z "$config_file_path" ]]; then
        current_dir=$(dirname "$current_file")
        if [ -z "$current_dir" ]; then
            echo "Cannot determine current directory" >&2
            exit 1
        fi

        source "$current_dir/config.cfg"
        if [ $? -ne 0 ]; then
            echo "Cannot source config.cfg" >&2
            exit 1
        fi
    else
        source "$config_file_path"
        if [ $? -ne 0 ]; then
            echo "Cannot source $config_file_path" >&2
            exit 1
        fi
    fi

    if [ -z "$KEYS_CONFIGURATION_FILE" ]; then
        echo "KEYS_CONFIGURATION_FILE is not set in config.cfg" >&2
        exit 1
    fi

    if [ -z "$KEYS_PASSPHRASES_FILE" ]; then
        echo "KEYS_PASSPHRASES_FILE is not set in config.cfg" >&2
        exit 1
    fi

    if [ ! -f "$KEYS_CONFIGURATION_FILE" ]; then
        echo "NOT FOUND $KEYS_CONFIGURATION_FILE" >&2
        exit 1
    fi

    if [ ! -f "$KEYS_PASSPHRASES_FILE" ]; then
        echo "NOT FOUND $KEYS_PASSPHRASES_FILE" >&2
        exit 1
    fi

    if [ -z "$SSH_KEYS_DIR" ]; then
        echo "SSH_KEYS_DIR is not set in config.cfg" >&2
        exit 1
    fi

    output=$(flock -s "$KEYS_CONFIGURATION_FILE" -c "
        bash -c '
            source \"$current_file\" && mainWithoutFlock \"$user\" \"$comment\" \"$KEYS_CONFIGURATION_FILE\" \"$SSH_KEYS_DIR\" \"$KEYS_PASSPHRASES_FILE\"
            exit \$?
        '")
    if [ $? -ne 0 ]; then
        echo "Problem occurred within remove: $output" >&2
        exit 1
    fi

    echo "$output"

    exit 0
}

function mainWithoutFlock {
    local user="$1"
    local comment="$2"
    local configuration_file="$3"
    local ssh_keys_dir="$4"
    local passphrases_file="$5"
    local configuration_array
    local length
    local i
    local existing_key
    local user_name
    local key_index
    local key_comment

    if [[ -z "$user" ]]; then
        echo "User must not be empty" >&2
        exit 1
    fi

    configuration_array=$(cat "$configuration_file")
    if [ $? -ne 0 ]; then
        echo "Cannot read users file" >&2
        exit 1
    fi

    length=$(echo "$configuration_array" | jq -r '. | length')
    if [ $? -ne 0 ]; then
        echo "Cannot get length of users array" >&2
        exit 1
    fi

    for (( i=0; i<length; i++ )); do
        existing_key=$(echo "$configuration_array" | jq -r ".[$i]")
        if [ $? -ne 0 ]; then
            echo "Cannot get user at index $i" >&2
            exit 1
        fi

        user_name="$(echo "$existing_key" | jq -r '.user')"
        if [ $? -ne 0 ]; then
            echo "Cannot get user name at index $i" >&2
            exit 1
        fi
        key_index="$(echo "$existing_key" | jq -r '.index')"
        if [ $? -ne 0 ]; then
            echo "Cannot get key index at index $i" >&2
            exit 1
        fi
        key_comment="$(echo "$existing_key" | jq -r '.comment')"
        if [ $? -ne 0 ]; then
            echo "Cannot get key comment at index $i" >&2
            exit 1
        fi

        if [[ "$user_name" == "$user" ]] && [[ "$key_comment" == "$comment" ]]; then

            echo "$key_index"

            break
        fi
    done

    exit 0
}