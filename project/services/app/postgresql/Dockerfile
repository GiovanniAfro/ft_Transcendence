FROM bitnami/postgresql:15.8.0

USER root

RUN apt-get update && apt-get install -y curl jq

# COPY conf/ /bitnami/postgresql/conf

USER 1001

COPY tools/entrypoint_wrapper.sh /entrypoint/
# COPY tools/create_roles.sql /docker-entrypoint-initdb.d/create_roles.sql

ENTRYPOINT ["bash", "-c", "source /entrypoint/entrypoint_wrapper.sh"]

CMD [ "/opt/bitnami/scripts/postgresql/entrypoint.sh", \
	"/opt/bitnami/scripts/postgresql/run.sh" ]
