FROM python:3.12.4-bookworm

# ARG 

WORKDIR /usr/src/app

COPY conf/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt \
	&& django-admin startproject ft_transcendence \ 
	&& python ft_transcendence/manage.py startapp pong \
	&& python ft_transcendence/manage.py migrate

# COPY conf/ft_transcendence/ft_transcendence/asgi.py ft_transcendence/ft_transcendence/asgi.py
# COPY conf/ft_transcendence/ft_transcendence/settings.py ft_transcendence/ft_transcendence/settings.py
# COPY conf/ft_transcendence/ft_transcendence/static ft_transcendence/ft_transcendence/static
# COPY conf/ft_transcendence/ft_transcendence/migrations ft_transcendence/ft_transcendence/

COPY conf/myproject myproject

EXPOSE 8000

CMD ["python", "myproject/manage.py", "runserver", "10.0.0.1:8000"]
