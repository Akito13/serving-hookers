#!/bin/bash
# See LICENSE.
# Copyright (C) 2019 Akito
# This script has only been successfully on a Debian based OS.
# If you want to have support for other bases, then create a pull request as described in README.md.

# Check if Go version is recent enough.
if ! [[ $(go version | grep 'go[1-9]\.[1-9][1-9].*.*') ]]; then
    echo "Go version too low or not installed. Please install Go version 1.11.2 or higher. Exiting.";
    echo
    echo "If using Raspberry Pi, you are welcome to use the following script:";
    echo "https://github.com/Akito13/serving-hookers/blob/master/go1.13.1_arm_bootstrap.sh";
    echo
    echo "Download directly by executing the following line: "
    echo "wget -q https://raw.githubusercontent.com/Akito13/serving-hookers/master/go1.13.1_arm_bootstrap.sh"
    exit 1
fi

# Check if NodeJS version is recent enough.
if ! [[ $(node -v | grep '[1-9][1-9]\..*.*') ]]; then
    echo "NodeJS version too low or not installed. Please install NodeJS version 11.0 or higher. Exiting.";
    exit 1
fi

# Cloning server files to sources directory.
	mkdir ~/src/ > /dev/null 2>&1;
    cd ~/src/ && \
    git clone https://github.com/gotify/server.git gotify-server && \
    cd gotify-server && \
# Getting dependencies and setting up build environment.
    make download-tools && \
    go get -d && \
    cd ui && \
    npm install && \
    npm run build && \
    packr && \
    cd .. && \
# Building gotify-server without using docker.
    export LD_FLAGS="-w -s -X main.Version=$(git describe --tags | cut -c 2-) -X main.BuildDate=$(date "+%F-%T") -X main.Commit=$(git rev-parse --verify HEAD) -X main.Mode=prod"; && \
    go build -ldflags="$LD_FLAGS" -o gotify-server && \
    echo -e "\nInstalled gotify-server successfully."

exit 0