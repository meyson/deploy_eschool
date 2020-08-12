#!/usr/bin/env bash

mysql_create_user() {
mysql << EOF
CREATE USER '$1'@'$3' IDENTIFIED BY '$2';
GRANT ALL PRIVILEGES ON * . * TO '$1'@'$3';
FLUSH PRIVILEGES;
EOF
}

install_mariadb() {
  yum install -y mariadb-server
  systemctl start mariadb
  systemctl enable mariadb

  # allow access from outside
  sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/my.cnf.d/mariadb-server.cnf

  firewall-cmd --permanent --zone=trusted --add-port=3306/tcp
  firewall-cmd --reload
}

install_mariadb
mysql -e "CREATE DATABASE $DATABASE;" 2>/dev/null
mysql_create_user "$DB_USER_NAME" "$DB_USER_PWD" "$BE_SERVER_1"
mysql_create_user "$DB_USER_NAME" "$DB_USER_PWD" "$BE_SERVER_2"
systemctl restart mariadb
