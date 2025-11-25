function main {
    local user
    local comment

    local last_action
    local current_file
    local current_dir
    local key_index

    echo "Please enter user (comment):"
    read user
    if [ -z "$user" ]; then
        echo "We do not allow empty user" >&2
        exit 1
    fi

    echo "Please enter comment (can be empty):"
    read comment

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
    

    source "$current_dir/config.cfg"
    if [ $? -ne 0 ]; then
        echo "Cannot source config.cfg" >&2
        exit 1
    fi

    if [ -z "$BASIC_DIR" ]; then
        echo "BASIC_DIR is not set in config.cfg" >&2
        exit 1
    fi

    key_index=$(source "$BASIC_DIR/get.sh" && main "$user" "$comment")
    if [ $? -ne 0 ]; then
        echo "Problem within get: $key_index" >&2
        exit 1
    fi

    echo "Key index: $key_index"

    exit 0
}