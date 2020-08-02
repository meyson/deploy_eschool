#!/usr/bin/env bash

# todo check env vars

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
mysql -e "CREATE DATABASE $DATABASE;"
mysql_create_user "$DB_USER_NAME" "$DB_USER_PWD" "$DB_USER_HOST"
service mysql restart
