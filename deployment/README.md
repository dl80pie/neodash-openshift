# NeoDash OpenShift Deployment Guide

This guide explains how to deploy NeoDash in an OpenShift environment using the provided configuration files.

## Overview

The deployment consists of:
- A custom Docker image based on `neo4j/neodash:latest` optimized for OpenShift
- Configuration via ConfigMaps instead of runtime scripts
- OpenShift deployment manifests (Deployment, Service, Route, ConfigMap)

## Prerequisites

- Access to an OpenShift cluster
- `oc` command-line tool installed and configured
- Podman or Docker for building the container image

## Building the OpenShift-compatible Image

1. From the project root directory, run the build script:
   ```bash
   ./scripts/build-openshift-image.sh
   ```

2. This will create a container image named `neodash-openshift:latest` (or with the tag specified by the `IMAGE_TAG` environment variable).

3. Push the image to your container registry:
   ```bash
   podman tag neodash-openshift:latest <your-registry>/neodash-openshift:latest
   podman push <your-registry>/neodash-openshift:latest
   ```

## Configuration

The configuration is managed via ConfigMaps instead of environment variables and runtime scripts:

1. Edit the `configmap.yaml` file to customize your NeoDash configuration:
   - Connection settings to your Neo4j database
   - UI customization options
   - Feature toggles

2. Update the image reference in `deployment.yaml` to point to your registry:
   ```yaml
   image: <your-registry>/neodash-openshift:latest
   ```

## Deployment

1. Create a new project in OpenShift (optional):
   ```bash
   oc new-project neodash
   ```

2. Apply the configuration:
   ```bash
   oc apply -f openshift/configmap.yaml
   oc apply -f openshift/deployment.yaml
   oc apply -f openshift/service.yaml
   oc apply -f openshift/route.yaml
   ```

3. Verify the deployment:
   ```bash
   oc get pods
   oc get routes
   ```

## Accessing NeoDash

Once deployed, you can access NeoDash through the Route URL:
```bash
oc get route neodash -o jsonpath='{.spec.host}'
```

## Troubleshooting

If you encounter issues:

1. Check pod status:
   ```bash
   oc get pods
   oc describe pod <pod-name>
   ```

2. View logs:
   ```bash
   oc logs <pod-name>
   ```

3. Verify ConfigMap is correctly mounted:
   ```bash
   oc exec <pod-name> -- cat /usr/share/nginx/html/config.json
   ```

## Security Considerations

- The container runs as a non-root user
- OpenShift's security context constraints are respected
- Sensitive configuration (database credentials) should be stored in Secrets rather than ConfigMaps for production use

## Customizing the Configuration

For production use, consider:
1. Creating separate ConfigMaps for different environments
2. Using Secrets for sensitive information
3. Implementing health checks specific to your environment
4. Setting appropriate resource limits based on your usage patterns
