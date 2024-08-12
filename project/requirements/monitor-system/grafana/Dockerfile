FROM grafana/grafana:main-ubuntu

COPY conf/9628_rev7.json /usr/local/grafana/conf/
COPY tools/set_data_source.sh /entrypoint/
COPY tools/entrypoint.sh /entrypoint/
