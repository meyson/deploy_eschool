#!/usr/bin/env bash

# install jre and run app
yum install -y java-1.8.0-openjdk
cp "/app/eschool.jar" ~/
java -jar ~/eschool.jar &