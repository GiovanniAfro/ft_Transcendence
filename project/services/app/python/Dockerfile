FROM bitnami/python:3.12.6

COPY conf/ ./
COPY tools/ /entrypoint/

RUN apt-get update && apt-get install -y curl jq netcat-openbsd && \
	pip install --no-cache-dir -r requirements.txt
