FROM bitnami/python:3.12.6

COPY conf/requirements.txt ./
COPY conf/pong_project ./pong_project
COPY tools/ /entrypoint/

USER root

RUN apt-get update && apt-get install -y curl jq && \
	pip install --no-cache-dir -r requirements.txt

USER 1001
