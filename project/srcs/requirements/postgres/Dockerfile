FROM debian:stable

# ARG POSTGRES_PASSWORD
# ARG POSTGRES_DB_NAME
# ARG POSTGRES_DB_USER
# ARG POSTGRES_DB_PASS

COPY tools/entrypoint.sh /tmp/entrypoint.sh

RUN apt-get update \
    && apt-get upgrade \
    && apt-get install -y postgresql \
    && apt-get install -y iproute2 net-tools vim tree curl sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && chmod +x /tmp/entrypoint.sh


# RUN chmod +x /tmp/entrypoint.sh && /tmp/entrypoint.sh

EXPOSE 5432

# USER postgres

ENTRYPOINT [ "/tmp/entrypoint.sh" ]
# CMD ["tail", "-f"]
# CMD ["postgres", "-D", "/var/lib/postgresql/data", "-c", "config_file=/etc/postgresql/15/main/postgresql.conf"]
