#!/bin/bash

function main {
    local user="$1"
    local password="$2"
    local is_user_exists

    local directory_path="/home/$user"

    is_user_exists=$(isUserExists "$user")
    if [ $? -ne 0 ]; then
        echo "Error within isUserExists: $is_user_exists" >&2
        exit 1
    fi

    if [[ "$is_user_exists" == "false" ]]; then
        last_action=$(createUser "$user" "$password")
        if [ $? -ne 0 ]; then
            echo "Error within useradd: $last_action" >&2
            exit 1
        fi
    fi

    # Case when user is root
    if [[ "$user" == "root" ]]; then
        directory_path="/root"
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

    exit 0
}

function isUserExists {
    local user="$1"
    local is_user_exists

    source /working-env/ubuntu/user-work/is-user-exists.sh
    if [ $? -ne 0 ]; then
        echo "Cannot source is-user-exists.sh" >&2
        exit 1
    fi

    is_user_exists=$(main "$user")
    if [ $? -ne 0 ]; then
        echo "Error within is-user-exists.sh: $is_user_exists" >&2
        exit 1
    fi

    echo "$is_user_exists"
    exit 0
}

# This is just a wrapper over create.sh to handle errors properly
function createUser {
    local user="$1"
    local password="$2"
    local last_action

    source /working-env/ubuntu/user-work/create.sh
    if [ $? -ne 0 ]; then
        echo "Cannot source create.sh" >&2
        exit 1
    fi

    last_action=$(main "$user" "$password")
    if [ $? -ne 0 ]; then
        echo "Error within create.sh: $last_action" >&2
        exit 1
    fi

    exit 0
}