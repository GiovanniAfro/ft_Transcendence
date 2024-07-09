#!/bin/bash

set -e 

django-admin startproject test_project
python manage.py startapp pong
python manage.py makemigrations pong
# sed -i '1i\
# import environ\n\
# env = environ.Env()' test_project/test_project/settings.py
# sed -i "s/^ALLOWED_HOSTS = \[\]$/ALLOWED_HOSTS = env.list('ALLOWED_HOSTS', default=[])/" test_project/test_project/settings.py

python test_project/manage.py migrate
python test_project/manage.py runserver 10.0.0.1:8000
