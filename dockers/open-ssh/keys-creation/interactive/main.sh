#!/bin/bash

function main {
    local action
    local getting_action_result
    local current_file
    local current_dir

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

    while true; do
        action=""
        getting_action_result=2
        while [ $getting_action_result -eq 2 ]; do
            getAction
            getting_action_result=$?
        done
        if [[ "$action" == "exit" ]]; then
            exit 0
        elif [[ $getting_action_result -eq 1 ]]; then
            echo "Problem within getAction" >&2
            exit 1
        fi

        echo "You have chosen action: $action"

        (source "$current_dir/$action.sh" && main)
        if [ $? -ne 0 ]; then
            echo "Problem within $action action" >&2
            exit 1
        fi
    done

    exit 0
}

function getAction {
    action=""
    echo "Please provide action that you want to perform. create/remove/exit"
    read action
    if [[ "$action" != "create" && "$action" != "remove" && "$action" != "exit" ]]; then
        if [[ "$action" == "exit" ]]; then
            return 3
        fi
        echo "Invalid action. Please specify 'create', 'remove' or 'exit'."
        action=""
        return 2
    fi
    return 0
}