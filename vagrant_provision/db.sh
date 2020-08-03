#!/usr/bin/env bash

mysql_create_user() {
mysql << EOF
CREATE USER '$1'@'$3' IDENTIFIED BY '$2';
GRANT ALL PRIVILEGES ON * . * TO '$1'@'$3';
FLUSH PRIVILEGES;
EOF
}

install_mysql() {
  apt update
  apt install -y mysql-server
  # allow access from outside
  echo "bind-address = $DB_SERVER_IP" >> /etc/mysql/mysql.conf.d/mysqld.cnf
}

install_mysql
mysql -e "CREATE DATABASE $DATABASE;" 2>/dev/null
mysql_create_user "$DB_USER_NAME" "$DB_USER_PWD" "$BE_SERVER_1"
mysql_create_user "$DB_USER_NAME" "$DB_USER_PWD" "$BE_SERVER_2"
service mysql restart
