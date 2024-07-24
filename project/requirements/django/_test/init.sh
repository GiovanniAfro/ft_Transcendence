#!/bin/bash

set -e

settings="/usr/src/app/ft_transcendence/ft_transcendence/settings.py"

# if [[ ! -d "/usr/src/app/ft_transcendence" ]]; then
# 	django-admin startproject ft_transcendence
# fi

# python ft_transcendence/manage.py startapp pong
# python ft_transcendence/manage.py makemigrations
python ft_transcendence/manage.py migrate
# mkdir -p ft_transcendence/static
# sed -i "s|ALLOWED_HOSTS = \[\]|ALLOWED_HOSTS = \['192.168.174.102'\]|" $settings
# sed -i "s|STATIC_URL = 'static/'|STATIC_URL = '/static/'|" $settings
echo "STATIC_ROOT = str(BASE_DIR) + '/staticfiles'" >> $settings
python ft_transcendence/manage.py collectstatic --noinput
python ft_transcendence/manage.py runserver 10.0.0.1:8000
