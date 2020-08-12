#!/usr/bin/env bash

# install jre and run app
yum install -y java-1.8.0-openjdk

firewall-cmd --permanent --zone=trusted --add-port=8080/tcp
firewall-cmd --reload

# fixme
setenforce 0

cp "/vagrant/build/app/eschool.jar" ~/
cp /vagrant/config_files/be_watcher.sh /usr/bin/

chmod +x /usr/bin/be_watcher.sh
crontab -l | { cat; echo "@reboot /usr/bin/be_watcher.sh"; } | crontab -
# this script is going to reload page
/usr/bin/be_watcher.sh &
