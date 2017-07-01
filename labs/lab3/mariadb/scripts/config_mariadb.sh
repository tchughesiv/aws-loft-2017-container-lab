#!/bin/bash

set -e

__mysql_config() {
  echo "Running the mysql_config function."
  mysql_install_db
#  chown -R mysql:mysql /var/lib/mysql
  /usr/bin/mysqld_safe &
  sleep 10
}

__setup_mysql() {
  printf "Running the start_mysql function.\n"
  ROOT_PASS="$(openssl rand -base64 12)"
  USER="${DBUSER-dbuser}"
  PASS="${DBPASS-$(openssl rand -base64 12)}"
  NAME="${DBNAME-db}"
  printf "root password=%s\n" "$ROOT_PASS"
  printf "NAME=%s\n" "$DBNAME"
  printf "USER=%s\n" "$DBUSER"
  printf "PASS=%s\n" "$DBPASS"
  mysqladmin -u root password "$ROOT_PASS"
  mysql -uroot -p"$ROOT_PASS" <<-EOF
	DELETE FROM mysql.user WHERE user = '$DBUSER';
	FLUSH PRIVILEGES;
	CREATE USER '$DBUSER'@'localhost' IDENTIFIED BY '$DBPASS';
	GRANT ALL PRIVILEGES ON *.* TO '$DBUSER'@'localhost' WITH GRANT OPTION;
	CREATE USER '$DBUSER'@'%' IDENTIFIED BY '$DBPASS';
	GRANT ALL PRIVILEGES ON *.* TO '$DBUSER'@'%' WITH GRANT OPTION;
	CREATE DATABASE $DBNAME;
EOF

  killall mysqld
  sleep 10
}

# Call all functions - only call if not already configured
DB_FILES=$(echo /var/lib/mysql/*)
DB_FILES="${DB_FILES#/var/lib/mysql/\*}"
DB_FILES="${DB_FILES#/var/lib/mysql/lost+found}"
if [ -z "$DB_FILES" ]; then
  printf "Initializing empty /var/lib/mysql...\n"
  __mysql_config
  __setup_mysql
fi
