# FROM postgres:16-bookworm


# RUN chmod +x /entrypoint/add_remote_host.sh \
# 	&& service postgresql restart

# USER postgres


FROM bitnami/postgresql:16

USER root

RUN apt-get update && apt-get install -y curl

USER 1001

COPY tools/ /entrypoint/
