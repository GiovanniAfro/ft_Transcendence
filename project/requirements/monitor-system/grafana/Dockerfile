FROM grafana/grafana:main-ubuntu

COPY conf/postgres-dashboard.json /var/lib/grafana/dashboards/
COPY tools/set_data_source.sh /entrypoint/
COPY tools/set_dashboards.sh /entrypoint/
COPY tools/entrypoint_wrapper.sh /entrypoint/
