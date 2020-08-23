#!/usr/bin/env bash

# script arguments
USER=$1
HOST=$2
SSH_KEY=$3
CREDS_PATH=$4
BE_STABLE_BUILD=$5
FE_STABLE_BUILD=$6

HOST_AND_USER="$USER@$HOST"
DIR="deploy_eschool"

# https://medium.com/@wblankenship/bash-automatically-populating-a-known-hosts-file-15ea28d06c02
# Add to known hosts
add_to_known() {
  ssh-keygen -F "$1" 2>/dev/null 1>/dev/null
  if [ $? -eq 0 ]; then
    echo "$1 is already known"
  else
    ssh-keyscan -t rsa -T 10 "$1" >> ~/.ssh/known_hosts
  fi
}

add_to_known "$HOST"
# send credentials form local machine
scp "$SSH_KEY" "$HOST_AND_USER":~/.ssh/
scp "$CREDS_PATH" "$HOST_AND_USER":~/$DIR

# wait for vagrant to setup infrastructure
sleep 20


# Start Back-end servers
ssh "$HOST_AND_USER" "python3 deploy_eschool/deploy.py -j $BE_STABLE_BUILD -p be --credentials credentials_eschool_prod.yaml"

# Start Front-end servers
ssh "$HOST_AND_USER" "python3 deploy_eschool/deploy.py -j $FE_STABLE_BUILD -p fe --credentials credentials_eschool_prod.yaml"
