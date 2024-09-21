FROM bitnami/nginx-exporter:1.3.0

USER root

RUN apt-get update && apt-get install -y curl jq

COPY --chown=1001:root conf/ /opt/bitnami/nginx-exporter/conf

USER 1001

COPY tools/ /entrypoint/

ENTRYPOINT ["bash", "-c", "source /entrypoint/entrypoint_wrapper.sh"]

CMD ["nginx-prometheus-exporter", \
	"--nginx.scrape-uri=https://10.0.4.1:8443", \
	"--nginx.ssl-ca-cert='/tmp/ca.crt'", \
	"--nginx.ssl-client-cert='/tmp/nginx-exporter.crt'", \
	"--nginx.ssl-client-key='/tmp/nginx-exporter.key'", \
	"--nginx.ssl-verify"]
