# Stage 1: Prepare the files using an Alpine image with root access
FROM alpine:3.18 as prepare

# Create placeholder config files
RUN mkdir -p /tmp/config
RUN echo "{}" > /tmp/config/config.json && \
    echo "{}" > /tmp/config/style.config.json

# Create a custom entrypoint script that skips the config-entrypoint.sh
RUN mkdir -p /tmp/scripts
COPY scripts/openshift-entrypoint.sh /tmp/scripts/openshift-entrypoint.sh
RUN chmod +x /tmp/scripts/openshift-entrypoint.sh

# Stage 2: Final image based on neodash
FROM neo4jlabs/neodash:latest

# Copy the prepared config files and custom entrypoint script
COPY --from=prepare /tmp/config/config.json /usr/share/nginx/html/config.json
COPY --from=prepare /tmp/config/style.config.json /usr/share/nginx/html/style.config.json
COPY --from=prepare /tmp/scripts/openshift-entrypoint.sh /openshift-entrypoint.sh

# Make the application directory writable by any uid in the root group (required for OpenShift random UID runtime)
USER root
RUN chgrp -R 0 /usr/share/nginx/html && \
    chmod -R g=u /usr/share/nginx/html && \
    chgrp -R 0 /var/cache/nginx && \
    chmod -R g=u /var/cache/nginx && \
    chgrp -R 0 /var/log/nginx && \
    chmod -R g=u /var/log/nginx && \
    chgrp -R 0 /etc/nginx/conf.d && \
    chmod -R g=u /etc/nginx/conf.d && \
    chgrp -R 0 /var/run && \
    chmod -R g=u /var/run

# OpenShift will run the container with an arbitrary non-root UID belonging to the root group (0).
# Set permissions for the entrypoint script
RUN chmod +x /openshift-entrypoint.sh

# Switch back to nginx user for running the container
USER nginx

# Use our custom entrypoint script
ENTRYPOINT ["/openshift-entrypoint.sh"]

# Default port (can be overridden via environment variable)
ENV NGINX_PORT=8080
EXPOSE 8080

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD curl --fail http://localhost:${NGINX_PORT} || exit 1

# Label the image
LABEL maintainer="OpenShift Deployment" \
      description="NeoDash for OpenShift with ConfigMap-based configuration"
