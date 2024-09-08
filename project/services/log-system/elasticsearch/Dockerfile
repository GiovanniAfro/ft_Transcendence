FROM bitnami/elasticsearch:8.15.0

USER root

RUN apt-get update && apt-get install -y curl jq

USER 1001

COPY tools/ /entrypoint/

# USER elasticsearch

# COPY --chown=elasticsearch:elasticsearch conf/logstash_writer.json /tmp/
# COPY --chown=elasticsearch:elasticsearch tools/lib.sh /tmp/
# COPY --chown=elasticsearch:elasticsearch tools/set_users.sh /tmp/
# COPY --chown=elasticsearch:elasticsearch tools/set_data_retention_policy.sh /tmp/
# COPY --chown=elasticsearch:elasticsearch tools/setup.sh /tmp/

# RUN chmod +x /tmp/setup.sh && chmod +x /tmp/set_data_retention_policy.sh
