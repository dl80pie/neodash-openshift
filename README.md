# NeoDash OpenShift Build

This directory contains all files needed to build and deploy NeoDash in an OpenShift environment.

## Directory Structure

- `Dockerfile` - OpenShift-compatible Dockerfile based on neo4jlabs/neodash:latest
- `scripts/` - Contains scripts for building and running NeoDash in OpenShift
  - `build-openshift-image.sh` - Script to build the OpenShift-compatible image
  - `openshift-entrypoint.sh` - Custom entrypoint script for OpenShift deployment
- `deployment/` - Contains Kubernetes/OpenShift deployment manifests
  - `deployment.yaml` - Deployment configuration
  - `service.yaml` - Service configuration
  - `route.yaml` - OpenShift Route configuration
  - `configmap.yaml` - ConfigMap for NeoDash configuration
  - `kustomization.yaml` - Kustomize configuration

## Building the Image

To build the OpenShift-compatible image:

```bash
cd openshift-build
./scripts/build-openshift-image.sh
```

This will create a container image tagged as `neodash-openshift:<git-tag>`.

## Deploying to OpenShift

To deploy NeoDash to OpenShift:

```bash
cd openshift-build/deployment
oc apply -k .
```

## Key Features

- Runs as non-root user compatible with OpenShift's random UID security model
- Configuration managed via ConfigMaps instead of runtime scripts
- Custom entrypoint script that handles nginx configuration in read-only filesystem
- All necessary files copied to writable locations at container startup
