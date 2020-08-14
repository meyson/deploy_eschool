#!/usr/bin/env bash

configure_lb() {
cat <<EOF > /etc/nginx/conf.d/lb.conf
upstream lb {
    ip_hash;
    server $SERVER_1:$PORT;
    server $SERVER_2:$PORT;
}

server {
        listen 80 default_server;
        listen [::]:80 default_server;

    location / {
        proxy_pass "http://lb";
    }
}
EOF
systemctl reload nginx
}

install_nginx() {
  yum install -y epel-release
  yum install -y nginx
  systemctl start nginx
  systemctl enable nginx
  setsebool httpd_can_network_connect on -P
  # fixme
  firewall-cmd --permanent --add-service=http
  firewall-cmd --reload
  sed -i "s|\s*default_server||g" /etc/nginx/nginx.conf
}

install_nginx
configure_lb
