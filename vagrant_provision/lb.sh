#!/usr/bin/env bash

configure_lb() {
cat <<EOF > /etc/nginx/conf.d/lb.conf
upstream lb {
    $1
    $2
}

# custom logs
log_format upstreamlog '[\$time_local] \$remote_addr - \$remote_user - \$server_name \$host to: \$upstream_addr: \$request \$status upstream_response_time \$upstream_response_time msec \$msec request_time \$request_time';

server {
        listen 80 default_server;
        listen [::]:80 default_server;

    location / {
        proxy_pass "http://lb";
    }
    access_log /var/log/nginx/access.log upstreamlog;
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

  firewall-cmd --permanent --add-service=http
  firewall-cmd --reload
  sed -i "s|\s*default_server||g" /etc/nginx/nginx.conf
}

servers=""
for server in "$@"
do
  servers+="server $server:$PORT; "
done

install_nginx

if [ "$TYPE" == "fe" ]; then
  # Use round robin
  configure_lb "" "$servers"
elif [ "$TYPE" == "be" ]; then
  # Use ip_hash
  configure_lb "ip_hash;" "$servers"
fi
