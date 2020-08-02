#!/usr/bin/env bash

# TODO configure proxy
# TODO configure https

# install jre
yum install -y java-1.8.0-openjdk

cp "/$DIST_DIR_BE/eschool.jar" ~/

java -jar ~/eschool.jar &