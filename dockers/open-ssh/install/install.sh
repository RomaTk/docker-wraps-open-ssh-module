#!/bin/bash

configure_options="$1"

cd ./saved-versions
[ $? -ne 0 ] && exit 1

dest_folder="./downloaded"

if [ ! -d "$dest_folder" ]; then
    mkdir -p "$dest_folder"
    [ $? -ne 0 ] && exit 1
fi

tar -xzf "downloaded.tar.gz" -C "$dest_folder" --strip-components=1
[ $? -ne 0 ] && exit 1

cd "$dest_folder"
[ $? -ne 0 ] && exit 1

apt install -y \
    build-essential \
    zlib1g-dev \
    libssl-dev
[ $? -ne 0 ] && exit 1

(eval "./configure ${configure_options}")
[ $? -ne 0 ] && exit 1

make install
[ $? -ne 0 ] && exit 1

apt-mark auto \
    build-essential \
    zlib1g-dev \
    libssl-dev
[ $? -ne 0 ] && exit 1

apt autoremove -y

exit 0