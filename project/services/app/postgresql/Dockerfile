FROM bitnami/postgresql:15.8.0

USER root

RUN apt-get update && apt-get install -y curl jq

USER 1001

COPY conf/ /tmp/
COPY tools/entrypoint_wrapper.sh /entrypoint/

ENTRYPOINT ["bash", "-c", "source /entrypoint/entrypoint_wrapper.sh"]

CMD [ "/opt/bitnami/scripts/postgresql/entrypoint.sh", \
	"/opt/bitnami/scripts/postgresql/run.sh" ]
