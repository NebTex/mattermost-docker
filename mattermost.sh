#!/usr/bin/dumb-init /bin/sh
set -e

DB_HOST=`cat /etc/db_host`
DB_PORT=`cat /etc/db_port`

echo "Wait until database ${DB_HOST:?}:${DB_PORT} is ready..."
until nc -z ${DB_HOST:?} ${DB_PORT}

do
    sleep 1
done

# Wait to avoid "panic: Failed to open sql connection pq: the database system is starting up"
sleep 1

cd /mattermost/bin
./platform