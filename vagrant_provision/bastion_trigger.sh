#!/usr/bin/env bash

SERVER=$1
scp ~/.ssh/id_rsa "$SERVER":~/.ssh/
scp ./remote_configs/deploy.py "$SERVER":~/
scp ~/.circlecitoken "$SERVER":~/
