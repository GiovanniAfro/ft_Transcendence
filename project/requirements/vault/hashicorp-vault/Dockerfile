FROM bitnami/vault:1.17.5

# USER 1001

COPY --chown=vault:root conf/ /bitnami/vault/config/
COPY --chown=vault:root tools/ /bitnami/vault/entrypoint/

RUN chmod +x /bitnami/vault/entrypoint/entrypoint_wrapper.sh
