#!/bin/bash

function main {
    local array
    local length
    local i
    local user
    local index

    array=$(cat ./keys/keys-configuration.json)
    if [ $? -ne 0 ]; then
        echo "Cannot read keys-configuration.json" >&2
        exit 1
    fi

    length=$(echo "$array" | jq -r '. | length')
    if [ $? -ne 0 ]; then
        echo "Cannot get length of JSON array" >&2
        exit 1
    fi
    

    for (( i=0; i<length; i++ )); do
        user=$(echo "$array" | jq -r ".[$i].user")
        if [ $? -ne 0 ]; then
            echo "Cannot get user for index $i" >&2
            exit 1
        fi

        if [[ -z "$user" ]]; then
            echo "User is empty for index $i" >&2
            exit 1
        fi

        index=$(echo "$array" | jq -r ".[$i].index")
        if [ $? -ne 0 ]; then
            echo "Cannot get index for user $user" >&2
            exit 1
        fi

        (
            source ./create-user.sh
            if [ $? -ne 0 ]; then
                echo "Cannot source create-user.sh" >&2
                exit 1
            fi
            main "$user" "$(gpg --gen-random --armor 1 32)"
        )
        if [ $? -ne 0 ]; then
            echo "Problem with creating $user" >&2
            exit 1
        fi

        (
            source ./create-ssh-folder.sh
            if [ $? -ne 0 ]; then
                echo "Cannot source create-ssh-folder.sh" >&2
                exit 1
            fi
            main "$user"
        )
        if [ $? -ne 0 ]; then
            echo "Problem with creating SSH folder for $user" >&2
            exit 1
        fi

        (
            source ./create-authorized-keys-file.sh
            if [ $? -ne 0 ]; then
                echo "Cannot source create-authorized-keys-file.sh" >&2
                exit 1
            fi
            main "$user"
        )
        if [ $? -ne 0 ]; then
            echo "Problem with creating authorized_keys file for $user" >&2
            exit 1
        fi

        (
            source ./add-key.sh
            if [ $? -ne 0 ]; then
                echo "Cannot source add-key.sh" >&2
                exit 1
            fi
            main "$user" "$index"
        )
        if [ $? -ne 0 ]; then
            echo "Problem with adding public key for $user" >&2
            exit 1
        fi


    done

    exit 0
}

main