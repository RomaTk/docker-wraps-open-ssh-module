#!/bin/bash

function main {
    local latest_version
    latest_version=$(getVersion)
    if [ $? -ne 0 ]; then
        echo "Error getting latest version"
        exit 1
    fi

    echo "LATEST_VERSION=\"$latest_version\"" > /working-env/open-ssh/configs/latest-version.cfg
    if [ $? -ne 0 ]; then
        echo "Error writing latest version to config file"
        exit 1
    fi

    exit 0
}

function getVersion {
    local api_url
    local data_by_api
    local latest_version_tag
    local latest_version
    local page=1

    while true; do
        api_url="https://api.github.com/repos/openssh/openssh-portable/tags?page=$page"

        data_by_api=$(wget -c -qO- "$api_url")
        [ $? -ne 0 ] && exit 1

        latest_version_tag=$( echo "$data_by_api" | jq -r '(.[] | .name)' | head -n 1)
        [ $? -ne 0 ] && exit 1

        if [ -n "$latest_version_tag" ]; then
            break
        fi

        page=$((page + 1))
    done

    if [ -z "$latest_version_tag" ]; then
        echo "Failed to extract latest version tag"
        exit 1
    fi

    latest_version="${latest_version_tag}"
    [ $? -ne 0 ] && exit 1

    if [ -z "$latest_version" ]; then
        echo "Failed to extract latest version"
        exit 1
    fi

    echo "$latest_version"

    exit 0
}