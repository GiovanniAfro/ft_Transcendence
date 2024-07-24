ARG ELASTIC_VERSION

# https://www.docker.elastic.co/
FROM docker.elastic.co/logstash/logstash:${ELASTIC_VERSION}

# Add your logstash plugins setup here
# Example: RUN logstash-plugin install logstash-filter-json

USER logstash

COPY --chown=logstash:logstash tools/setup.sh /tmp/
COPY --chown=logstash:logstash tools/lib.sh /tmp/
COPY --chown=logstash:logstash tools/set_users.sh /tmp/
COPY --chown=logstash:logstash conf/logstash_writer.json /tmp/

RUN chmod +x /tmp/setup.sh && /tmp/setup.sh
