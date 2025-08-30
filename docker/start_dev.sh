#!/bin/bash

HOMEDIR=/home/ubuntu

SSH_KEY=${HOMEDIR}/.ssh/${SSH_KEY_FILE}
SSH_PUBLIC_KEY=${HOMEDIR}/.ssh/${SSH_KEY_FILE}.pub

docker run -it --name dev01 \
    -e AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION}" \
    -e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
    -e AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
    -e SSH_KEY="${SSH_KEY}" \
    -e SSH_PUBLIC_KEY="${SSH_PUBLIC_KEY}" \
    -e GITNAME="${GITNAME}" \
    -e GITEMAIL="${GITEMAIL}" \
    --volume ${SSH_KEY_DIR}:${HOMEDIR}/.ssh \
    devcontainer
    
