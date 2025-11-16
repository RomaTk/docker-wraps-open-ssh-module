#!/bin/bash

function main {
    local key_name="$1"
    local host="$2"
    local port_number="$3"
    local additional_options="$4"
    local command_in_ssh="$5"
    local is_interactive="$6"
    local keys_folder="$7"
    local user_name
    local passphrase
    local script_folder

    local key_file
    local output
    local exit_code
    local is_to_remove_ssh_agent="false"
    local is_to_remove_key="true"
    local command

    script_folder=$(dirname "${BASH_SOURCE[0]}")
    if [ $? -ne 0 ]; then
        echo "Cannot get directory name of the current file: ${BASH_SOURCE[0]}" >&2
        exit 1
    fi

    if [ -z "$keys_folder" ]; then
        keys_folder="$script_folder/keys"
    fi

    

    key_file="$keys_folder/$key_name"
    if [ ! -f "$key_file" ]; then
        echo "Key file does not exist: $key_file" >&2
        exit 1
    fi

    if [ -z "$port_number" ]; then
        port_number="22"
    fi
    
    # USER NAME HANDLING
    if [ -z "$host" ]; then
        echo "Host is required." >&2
        exit 1
    fi

    user_name=$(findUserName "$key_name")
    exit_code=$?
    if [ $exit_code -eq 2 ]; then
        if [ "$is_interactive" == "true" ]; then
            echo "User name for key '$key_name' not found in configuration."
            echo "Please enter the user name to connect as:"
            read user_name
        else
            echo "User name for key '$key_name' not found in configuration and not in interactive mode." >&2
            exit 1
        fi
    elif [ $exit_code -ne 0 ]; then
        echo "Error occurred while looking up user name for key '$key_name'." >&2
        exit 1
    fi

    host="${user_name}@${host}"

    # PASSPHRASE HANDLING
    passphrase=$(getPassphrase "$key_name")
    exit_code=$?
    if [ $exit_code -eq 2 ]; then
        if [ "$is_interactive" == "true" ]; then
            echo "Passphrase for key '$key_name' not found in configuration."
            echo "Please enter the passphrase for the key (leave empty for no passphrase):"
            read -s passphrase
        else
            echo "Passphrase for key '$key_name' not found in configuration and not in interactive mode." >&2
            exit 1
        fi
    elif [ $exit_code -ne 0 ]; then
        echo "Error occurred while looking up passphrase for key '$key_name'." >&2
        exit 1
    fi

    # ADD KEY TO SSH AGENT
    addSSHKeyToAgent "$key_file" "$passphrase"
    exit_code=$?

    if [ $exit_code -eq 2 ]; then
        # Clean up the ssh-agent process we started
        is_to_remove_ssh_agent="true"
    elif [ $exit_code -eq 3 ]; then
        # Key is already in the agent
        is_to_remove_key="false"
    elif [ $exit_code -ne 0 ]; then
        echo "Error occurred while adding key '$key_name' to ssh-agent." >&2
        exit 1
    fi

    # CONNECT VIA SSH

    command="ssh -q -i \"$key_file\" -o StrictHostKeyChecking=no -p \"$port_number\""
    if [ -z "$additional_options" ]; then
        command="$command"
    else
        command="$command $additional_options"
    fi
    command="$command \"$host\""
    
    command_in_ssh="${command_in_ssh//\"/\\\\\\\"}"
    if [ -n "$command_in_ssh" ]; then
        command="$command \"$command_in_ssh\""
    fi

    (eval "$command")
    exit_code=$?


    
    # CLEAN UP
    if [ "$is_to_remove_key" == "true" ]; then
        ssh-add -d "$key_file" > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "Warning: Failed to remove key '$key_name' from ssh-agent." >&2
            exit 1
        fi
    fi

    if [ "$is_to_remove_ssh_agent" == "true" ]; then
        ssh-agent -k > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "Warning: Failed to stop ssh-agent." >&2
            exit 1
        fi
    fi

    exit $exit_code
}

function findUserName {
    local key_index_to_find="$1"
    local file_path="$keys_folder/keys-configuration.json"
    local array
    local length
    local i
    local key_index
    local user_name

    if [ ! -f "$file_path" ]; then
        exit 2
    fi

    array=$(cat "$file_path")
    if [ $? -ne 0 ]; then
        echo "Cannot read configuration file" >&2
        exit 1
    fi

    length=$(echo "$array" | jq -r '. | length')
    if [ $? -ne 0 ]; then
        echo "Cannot determine length of configuration array" >&2
        exit 1
    fi

    for (( i=0; i<length; i++ )); do
        key_index=$(echo "$array" | jq -r ".[$i].index")
        if [ $? -ne 0 ]; then
            echo "Cannot extract key index from configuration file" >&2
            exit 1
        fi

        if [ "$key_index_to_find" == "$key_index" ]; then

            user_name=$(echo "$array" | jq -r ".[$i].user")
            if [ $? -ne 0 ]; then
                echo "Cannot extract user name from configuration file" >&2
                exit 1
            fi

            echo "$user_name"
            exit 0
        fi
    done

    exit 2
}

function getPassphrase {
    local file_path="$keys_folder/keys-passphrases.json"
    local passphrase

    if [ ! -f "$file_path" ]; then
        exit 2
    fi

    passphrase=$(jq -r ".\"$key_name\"" "$file_path")
    if [ $? -ne 0 ]; then
        echo "Cannot read passphrase from configuration file" >&2
        exit 1
    fi

    if [ "$passphrase" == "null" ]; then
        exit 2
    fi

    echo "$passphrase"
    exit 0

}

function addSSHKeyToAgent {
    local key_file="$1"
    local passphrase="$2"

    local try_count=0
    local key_was_added="true"

    while true; do
        (eval "$script_folder/ssh-agent-expect.sh \"$key_file\" \"$passphrase\"") > /dev/null 2>&1
        exit_code=$?
        if [ $exit_code -eq 2 ]; then
            if [ $try_count -gt 0 ]; then
                echo "Failed to add key '$key_name' to ssh-agent after multiple attempts." >&2
                exit 1
            fi
            eval $(ssh-agent -s) > /dev/null 2>&1
            if [ $? -ne 0 ]; then
                echo "Failed to start ssh-agent." >&2
                exit 1
            fi
            try_count=$((try_count + 1))
        elif [ $exit_code -eq 3 ]; then
            key_was_added="false"
            # Key is already in the agent, no action needed
            break
        elif [ $exit_code -ne 0 ]; then
            echo "Failed to add key '$key_name' to ssh-agent." >&2
            exit 1
        else
            break
        fi
    done

    if [ $try_count -gt 0 ]; then
        # Clean up the ssh-agent process we started
        return 2
    fi

    if [ "$key_was_added" == "false" ]; then
        return 3
    fi

    return 0
}