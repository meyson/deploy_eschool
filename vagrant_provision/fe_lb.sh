configure_lb() {
cat <<EOF > /etc/nginx/conf.d/lb.conf
upstream lb {
    server $FE_SERVER_1;
    server $FE_SERVER_2;
}

server {
    listen $FE_LB_IP:80;

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
