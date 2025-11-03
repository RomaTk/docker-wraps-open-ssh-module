#!/bin/bash

user_name="sshd"

is_user_exists=$(
    source /working-env/ubuntu/user-work/is-user-exists.sh
    if [ $? -ne 0 ]; then
        echo "Cannot source is-user-exists.sh" >&2
        exit 1
    fi

    main "$user_name"
)
if [ $? -ne 0 ]; then
    echo "Error within is-user-exists.sh: $is_user_exists" >&2
    exit 1
fi

if [[ "$is_user_exists" == "true" ]]; then
    echo "User exists."
    exit 0
fi

source "/working-env/ubuntu/user-work/create.sh"
if [ $? -ne 0 ]; then
    echo "Cannot source create.sh" >&2
    exit 1
fi

output=$(main "$user_name" "$(gpg --gen-random --armor 1 32)")
if [ $? -ne 0 ]; then
    echo "Error within main: $output" >&2
    exit 1
fi

exit 0