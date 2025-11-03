#!/bin/bash

function main {
    echo "Starting OpenSSH download script..."

    local config_file="./configs/versions.cfg"
    local dir_name="./saved"
    local version
    local os
    local arch
    local file_name
    local is_already_downloaded
    local what_to_download

    if [[ -f "$config_file" ]]; then
        source "$config_file"
        [ $? -ne 0 ] && exit 1
    else
        echo "Configuration file $config_file does not exist."
        exit 0
    fi

    if [[ -z "${VERSIONS+x}" ]]; then
        exit 0
    fi

    (createDirectoryIfNecessary "$dir_name")
    [ $? -ne 0 ] && exit 1

    for what_to_download in "${VERSIONS[@]}"; do
        IFS='/' read -r -a parts <<< "$what_to_download"
        if [[ ${#parts[@]} -ne 3 ]]; then
            echo "Invalid format in VERSIONS: $what_to_download. Expected format: os/arch/version"
            exit 1
        fi
        os="${parts[0]}"
        arch="${parts[1]}"
        version="${parts[2]}"
        echo "Installing OpenSSH version: $version for OS: $os and Architecture: $arch"
        # Here you would add the commands to install the specific version of OpenSSH

        file_name=$(getFileVersionName "$os" "$arch" "$version" "$dir_name")
        [ $? -ne 0 ] && exit 1
        is_already_downloaded=$(checkIsFileAlreadyDownloaded "$file_name")
        [ $? -ne 0 ] && exit 1

        if [[ "$is_already_downloaded" == "true" ]]; then
            echo "File $file_name already exists."
            continue
        fi

        echo "Downloading OpenSSH version: $version"
        (wget -c "https://github.com/openssh/openssh-portable/archive/refs/tags/${version}.tar.gz" -O "$file_name")
        [ $? -ne 0 ] && exit 1

    done

    exit 0
}

function getFileVersionName {
    local os="$1"
    local arch="$2"
    local version="$3"
    local dir_name="$4"
    echo "$dir_name/${version}.tar.gz"
    exit 0
}

function checkIsFileAlreadyDownloaded {
    local file_name="$1"

    if [[ -f "$file_name" ]]; then
        echo "true"
        exit 0
    fi

    echo "false"
    exit 0
}

function createDirectoryIfNecessary {
    local dir_name="$1"

    if [[ ! -d "$dir_name" ]]; then
        mkdir -p "$dir_name"
        [ $? -ne 0 ] && exit 1
    fi

    exit 0
}