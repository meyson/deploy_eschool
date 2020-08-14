#!/usr/bin/env bash

SERVER="$SSH_USER@$LB_BE_EXT_IP"
scp ~/.ssh/id_rsa "$SERVER":~/.ssh/
scp ./config_files/deploy.py "$SERVER":~/
scp ~/.circlecitoken "$SERVER":~/
