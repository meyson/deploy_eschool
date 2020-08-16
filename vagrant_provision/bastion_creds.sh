#!/usr/bin/env bash

HOST_AND_USER=$1
SSH_KEY=$2
DB_CREDS_PATH=$3
CIRCLE_CI_PATH=$4

DIR="deploy_eschool"
# send credentials form local machine
scp "$SSH_KEY" "$HOST_AND_USER":~/.ssh/
scp "$DB_CREDS_PATH" "$HOST_AND_USER":~/$DIR
scp "$CIRCLE_CI_PATH" "$HOST_AND_USER":~/$DIR
