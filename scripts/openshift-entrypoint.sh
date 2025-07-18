#!/bin/sh
# Custom entrypoint script for OpenShift deployment
set -e

# Execute only the necessary entrypoint scripts, skipping config-entrypoint.sh
echo "Starting NeoDash with OpenShift-compatible entrypoint..."

# Run IPv6 configuration script
if [ -f /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh ]; then
    echo "Running IPv6 configuration..."
    /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
fi

# Source local resolvers
if [ -f /docker-entrypoint.d/15-local-resolvers.envsh ]; then
    echo "Sourcing local resolvers..."
    . /docker-entrypoint.d/15-local-resolvers.envsh
fi

# Run envsubst on templates
if [ -f /docker-entrypoint.d/20-envsubst-on-templates.sh ]; then
    echo "Running envsubst on templates..."
    /docker-entrypoint.d/20-envsubst-on-templates.sh
fi

# Tune worker processes
if [ -f /docker-entrypoint.d/30-tune-worker-processes.sh ]; then
    echo "Tuning worker processes..."
    /docker-entrypoint.d/30-tune-worker-processes.sh
fi

# Skip config-entrypoint.sh and message-entrypoint.sh
echo "Skipping config-entrypoint.sh and message-entrypoint.sh as configuration is provided via ConfigMaps"

# Start nginx with a modified configuration for OpenShift
echo "Starting nginx..."

# Create directories for nginx in /tmp which should be writable
mkdir -p /tmp/nginx/conf

# Copy all necessary nginx configuration files to writable location
cp /etc/nginx/nginx.conf /tmp/nginx/conf/
cp /etc/nginx/mime.types /tmp/nginx/conf/
cp -r /etc/nginx/conf.d /tmp/nginx/conf/

# Modify the copied nginx.conf to use a writable PID file location
sed -i 's|pid        /var/run/nginx.pid;|pid        /tmp/nginx/nginx.pid;|g' /tmp/nginx/conf/nginx.conf

# Update paths in the configuration files to point to the correct locations
sed -i 's|/etc/nginx/mime.types|/tmp/nginx/conf/mime.types|g' /tmp/nginx/conf/nginx.conf
sed -i 's|/etc/nginx/conf.d/|/tmp/nginx/conf/conf.d/|g' /tmp/nginx/conf/nginx.conf

# Run nginx with the modified configuration
exec nginx -c /tmp/nginx/conf/nginx.conf -g "daemon off;"
