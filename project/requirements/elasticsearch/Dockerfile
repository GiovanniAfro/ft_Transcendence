ARG ELASTIC_VERSION

FROM docker.elastic.co/elasticsearch/elasticsearch:${ELASTIC_VERSION}

COPY --chown=elasticsearch:elasticsearch tools/set_users.sh /tmp/
COPY --chown=elasticsearch:elasticsearch tools/lib.sh /tmp/
COPY --chown=elasticsearch:elasticsearch conf/logstash_writer.json /tmp/

RUN chmod +x /tmp/set_users.sh
