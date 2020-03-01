#!/usr/bin/env bash

CONTAINER=jagger:dev-env:latest
COMMAND=/bin/zsh
DISPLAY="$(hostname):0"
USER=$(whoami)

docker run \
    -it \
    --rm \
    --user=$USER \
    --workdir="/home/$USER" \
    -v "/c/Users/$USER:/home/$USER:rw" \
    -e DISPLAY \
    $CONTAINER \
    $COMMAND
