#!/usr/bin/env bash

# install jre and run app
yum install -y java-1.8.0-openjdk
cp "/$DIST_DIR_BE/eschool.jar" ~/
java -jar ~/eschool.jar &