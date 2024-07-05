#!/bin/bash

set -e

apt-get update -qq
apt-get install -y -qq netcat-openbsd

SUCCESS_MSG="Connection to ${DB_HOST} ${DB_PORT} port [tcp/postgresql] succeeded!"

while ! [[ "$OUTPUT" == *"$SUCCESS_MSG"* ]]; do
    OUTPUT=$(nc -zv ${DB_HOST} ${DB_PORT} 2>&1)
    if [[ "$OUTPUT" == *"$SUCCESS_MSG"* ]]; then
        echo "$SUCCESS_MSG"
    else
        echo "Connection to ${DB_HOST} ${DB_PORT} port [tcp/postgresql] failed. Retry ..."
    fi
    sleep 1
done

apt-get remove --purge -y -qq netcat-openbsd
apt-get clean -qq
rm -rf var/lib/apt/lists/*

python ft_transcendence/manage.py migrate
python ft_transcendence/manage.py runserver 10.0.0.1:8000
