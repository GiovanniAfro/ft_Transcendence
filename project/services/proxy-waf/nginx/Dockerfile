# FROM owasp/modsecurity-crs:nginx

FROM bitnami/nginx:1.27.1

USER root

RUN apt-get update && apt-get install -y curl jq

USER 1001

COPY conf/ /opt/bitnami/nginx/conf/server_blocks/
COPY tools/ /entrypoint/

ENTRYPOINT ["bash", "-c", "source /entrypoint/entrypoint_wrapper.sh"]

CMD [ "/opt/bitnami/scripts/nginx/entrypoint.sh", \
	"/opt/bitnami/scripts/nginx/run.sh" ]
