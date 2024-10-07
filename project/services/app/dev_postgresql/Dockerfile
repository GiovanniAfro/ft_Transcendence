FROM bitnami/postgresql:15.8.0

COPY conf/ /tmp/
COPY tools/entrypoint_wrapper.sh /entrypoint/

ENTRYPOINT ["bash", "-c", "source /entrypoint/entrypoint_wrapper.sh"]

CMD [ "/opt/bitnami/scripts/postgresql/entrypoint.sh", \
	"/opt/bitnami/scripts/postgresql/run.sh" ]
