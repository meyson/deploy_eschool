configure_lb() {
cat <<EOF > /etc/nginx/conf.d/lb.conf
upstream lb {
    ip_hash;
    server $BE_SERVER_1:$BE_JAVA_PORT;
    server $BE_SERVER_2:$BE_JAVA_PORT;
}

server {
    listen $BE_LB_IP:80;

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
}

install_nginx
configure_lb
