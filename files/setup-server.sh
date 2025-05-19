#!/bin/bash
if [ -f /var/lib/mysql/.db_initialized ]; then
	exit
fi
isDBup () {
    mysql -uroot -e "SHOW STATUS" 1>/dev/null
    echo $?
}

RETRY=100
until [ $(isDBup) -eq 0 ] || [ $RETRY -le 0 ] ; do
    echo "... waiting for database to come up"
    sleep 5
    RETRY=$(( RETRY - 1))
done
if [ $RETRY -le 0 ]; then
    >&2 echo "... error: Could not connect to Database on $MYSQL_HOST:$MYSQL_PORT"
    exit 1
fi
echo "... DB is UP setup config"

set -x

mysql -uroot -e "create database $MYSQL_DATABASE"
mysql -uroot -e "grant usage on *.* to $MYSQL_USER@localhost identified by '$MYSQL_PASSWORD'"
mysql -uroot -e "grant all privileges on $MYSQL_DATABASE.* to $MYSQL_USER@localhost"
mysql -uroot -e "flush privileges;"
touch /var/lib/mysql/.db_initialized

echo "admin: root" >> /etc/aliases
newaliases
