FROM owasp/modsecurity-crs:nginx

USER root

RUN apt-get update && apt-get install -y curl jq 

USER nginx

COPY conf/ /etc/nginx/conf.d/
COPY tools/ /entrypoint/

ENTRYPOINT ["bash", "-c", "source /entrypoint/entrypoint_wrapper.sh"]
