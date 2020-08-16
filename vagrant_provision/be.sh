#!/usr/bin/env bash

user=$(id -un 1000)

# run command as another user
run_as(){
  sudo -H -u "$1" bash -c "$2"
}

# install software
yum install -y epel-release && yum update
yum install -y java-1.8.0-openjdk
yum --enablerepo=epel install -y inotify-tools
yum install -y wget

firewall-cmd --permanent --zone=trusted --add-port=8080/tcp
firewall-cmd --reload

dist_dir="/opt/eschool"
mkdir -p $dist_dir
chown -R "$user:$user" $dist_dir
cp "/vagrant/build/app/eschool.jar" "$dist_dir"
cp "/vagrant/remote_configs/be_watcher.sh" "$dist_dir"

# this script will reload java app when we deploy jar file
chmod +x "$dist_dir/be_watcher.sh"
run_as "$user" "bash $dist_dir/be_watcher.sh &"
# add watcher.sh to crontab
run_as "$user" "crontab -l | { cat; echo \"@reboot $dist_dir/be_watcher.sh\"; } | crontab -"
