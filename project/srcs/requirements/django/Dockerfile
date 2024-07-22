FROM python:3.12.4-bookworm

WORKDIR /usr/src/app

COPY conf/requirements.txt ./
COPY conf/ft_transcendence ./ft_transcendence
COPY tools/init_django.sh /tmp/

RUN pip install --no-cache-dir -r requirements.txt \
	&& chmod +x /tmp/init_django.sh

EXPOSE 8000

ENTRYPOINT ["/tmp/init_django.sh"]

# Test ------------------------------------------------------------------------>
# FROM python:3.12.4-bookworm
# WORKDIR /usr/src/app
# COPY conf/requirements.txt ./
# COPY _test/ft_transcendence ./ft_transcendence
# COPY _test/init.sh /tmp/
# # COPY tools/init_django.sh /tmp/
# RUN pip install --no-cache-dir -r requirements.txt \
# 	&& chmod +x /tmp/init.sh
# EXPOSE 8000
# ENTRYPOINT ["/tmp/init.sh"]
