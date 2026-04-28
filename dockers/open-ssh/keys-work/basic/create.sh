#!/bin/bash

function main {
    local user="$1"
    local comment="$2"
    local passphrase="$3"
    local config_file_path="$4"
    local output
    local fd
    local exit_code
    local current_file
    local current_dir

    if [[ -z "$user" ]] || [[ -z "$passphrase" ]]; then
        echo "User and passphrase must not be empty" >&2
        exit 1
    fi

    current_file="${BASH_SOURCE[0]}"
    if [ -z "$current_file" ]; then
        echo "Cannot determine current file" >&2
        exit 1
    fi

    current_dir=$(dirname "$current_file")
    if [ -z "$current_dir" ]; then
        echo "Cannot determine current directory" >&2
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

    current_file="${BASH_SOURCE[0]}"

    exec {fd}<> "$KEYS_CONFIGURATION_FILE"
    flock -x "$fd"

    output=$(
        source "$current_file" && mainWithoutFlock "$user" "$comment" "$passphrase" "$KEYS_CONFIGURATION_FILE" "$SSH_KEYS_DIR" "$KEYS_PASSPHRASES_FILE"
        exit $?
    )
    exit_code=$?

    exec {fd}>&-

    if [ $exit_code -ne 0 ]; then
        echo "Problem occurred within create: $output" >&2
        exit 1
    fi

    exit 0
}

function mainWithoutFlock {
    local user="$1"
    local comment="$2"
    local passphrase="$3"
    local configuration_file="$4"
    local ssh_keys_dir="$5"
    local passphrases_file="$6"
    local configuration_array
    local length
    local i
    local index="-1"
    local existing_key
    local user_name
    local key_index
    local key_comment
    local passphrases_obj

    if [[ -z "$user" ]] || [[ -z "$passphrase" ]]; then
        echo "User and passphrase must not be empty" >&2
        exit 1
    fi

    configuration_array=$(cat "$configuration_file")
    if [ $? -ne 0 ]; then
        echo "Cannot read users file" >&2
        exit 1
    fi

    passphrases_obj=$(cat "$passphrases_file")
    if [ $? -ne 0 ]; then
        echo "Cannot read passphrases file" >&2
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
            echo "Owner '$user' with comment '$comment' already exists in the file" >&2
            exit 1
        fi

        if [[ "$index" == "-1" ]] && [[ "$i" != "$key_index" ]]; then
            index="$i"
        fi
    done

    if [[ "$index" == "-1" ]]; then
        index="$length"
    fi

    configuration_array=$(echo "$configuration_array" | jq --arg user "$user" --arg index "$index" --arg comment "$comment" '. += [{
        "user": $user,
        "comment": $comment,
        "index": $index
    }]')
    if [ $? -ne 0 ]; then
        echo "Cannot add new user to array" >&2
        exit 1
    fi

    configuration_array=$(echo "$configuration_array" | jq -r 'sort_by(.index | tonumber)')
    if [ $? -ne 0 ]; then
        echo "Cannot sort users array" >&2
        exit 1
    fi

    passphrases_obj=$(echo "$passphrases_obj" | jq --arg index "$index" --arg passphrase "$passphrase" '. += {
        ($index): $passphrase
    }')
    if [ $? -ne 0 ]; then
        echo "Cannot add new passphrase to object" >&2
        exit 1
    fi

    ssh-keygen -t ed25519 -f "$ssh_keys_dir/$index" -C "$comment" -N "$passphrase"
    if [ $? -ne 0 ]; then
        echo "Cannot generate SSH key for user '$user'" >&2
        exit 1
    fi

    echo "$configuration_array" > "$configuration_file"
    if [ $? -ne 0 ]; then
        echo "Cannot write sorted users array to file" >&2
        exit 1
    fi

    echo "$passphrases_obj" > "$passphrases_file"
    if [ $? -ne 0 ]; then
        echo "Cannot write passphrases object to file" >&2
        exit 1
    fi

    exit 0
}