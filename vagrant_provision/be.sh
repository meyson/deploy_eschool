#!/usr/bin/env bash

user=$(id -un 1000)

# install software
yum install -y java-1.8.0-openjdk

firewall-cmd --permanent --zone=trusted --add-port=8080/tcp
firewall-cmd --reload

mkdir -p "$DIST_DIR"
chown -R "$user:$user" "$DIST_DIR"

