#!/usr/bin/env bash

# install dependencies
yum install -y wget python3
pip3 install requests paramiko pyyaml

# copy necessary files
DIR="/home/$REGULAR_USER/deploy_eschool/"
mkdir -p "$DIR"
cp /vagrant/remote_configs/deploy.py "$DIR"
cp /vagrant/config.yaml "$DIR"
chown "$REGULAR_USER:$REGULAR_USER" "$DIR" -R

