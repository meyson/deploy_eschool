##!/usr/bin/env bash

: "${FE_VHOST_NAME:?Need to set env variable FE_VHOST_NAME non-empty}"

install_httpd() {
  local httpd_config="/etc/httpd/conf/httpd.conf"

  yum install -y httpd
  systemctl start httpd
  systemctl enable httpd
  systemctl status httpd

  # create directories for vhosts
  mkdir -p /etc/httpd/sites-available /etc/httpd/sites-enabled

  if ! grep -q "IncludeOptional sites-enabled/\*\.conf" "$httpd_config"; then
    echo "IncludeOptional sites-enabled/*.conf" >> "$httpd_config"
  fi
}

configure_vhost() {
mkdir -p "/var/log/httpd/$1"
# add new host to /etc/apache2/sites-available directory
cat <<EOF > "/etc/httpd/sites-available/$1.conf"
<VirtualHost *:80>
    DocumentRoot /var/www/$1
    <Directory /var/www/$1>
        AllowOverride All
    </Directory>
    ErrorLog /var/log/httpd/$1/error.log
    CustomLog /var/log/httpd/$1/access.log combined
</VirtualHost>
EOF
# enable new host
ln -s /etc/httpd/sites-available/"$1".conf /etc/httpd/sites-enabled/"$1".conf 2>&1
}

copy_files() {
  mkdir -p /var/www/"$FE_VHOST_NAME"/
  cp -a /app/fe/. /var/www/"$FE_VHOST_NAME"
  chown -R vagrant:vagrant /var/www/"$FE_VHOST_NAME"
  chmod -R 755 /var/www
  chcon -R -t httpd_sys_content_t /var/www/"$FE_VHOST_NAME"/
}

install_httpd
configure_vhost "$FE_VHOST_NAME"
copy_files
setsebool -P httpd_unified 1
systemctl restart httpd
