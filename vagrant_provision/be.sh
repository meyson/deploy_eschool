#!/usr/bin/env bash
# TODO configure https

add_proxy() {
cat <<EOF > "/etc/nginx/conf.d/$1.conf"
server {
    listen         $2;
    location / {
        proxy_pass $3;
    }
}
EOF
}

install_nginx() {
  yum install -y epel-release
  yum install -y nginx
  systemctl start nginx
  systemctl enable nginx
  setsebool httpd_can_network_connect on -P
}

install_nginx
add_proxy "eschool" "192.168.60.10:80" "http://127.0.0.1:8080"
systemctl restart nginx

# install jre and run app
yum install -y java-1.8.0-openjdk
cp "/$DIST_DIR_BE/eschool.jar" ~/
java -jar ~/eschool.jar &