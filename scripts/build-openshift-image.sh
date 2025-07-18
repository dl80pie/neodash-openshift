#!/usr/bin/env bash
# build-openshift-image.sh – Build an OpenShift-compatible NeoDash container image

set -euo pipefail

# -----------------------------------------------------------------------------
# Configuration (can be overridden via environment variables)
# -----------------------------------------------------------------------------
IMAGE_NAME="${IMAGE_NAME:-neodash-openshift}"
IMAGE_TAG="${IMAGE_TAG:-$(git -C "$(dirname "$0")/../../" describe --tags --always 2>/dev/null || date +%Y%m%d)}"
PLATFORM="linux/amd64"
DOCKERFILE="Dockerfile"
CONTEXT_DIR="$(dirname "$0")/.." # Points to openshift-build directory
PROJECT_ROOT="$(dirname "$0")/../../" # Points to project root

# -----------------------------------------------------------------------------
# Build
# -----------------------------------------------------------------------------

echo "Building OpenShift-compatible image ${IMAGE_NAME}:${IMAGE_TAG} for platform ${PLATFORM} …"

podman build \
  --format oci \
  --platform "${PLATFORM}" \
  -f "${CONTEXT_DIR}/${DOCKERFILE}" \
  -t "${IMAGE_NAME}:${IMAGE_TAG}" \
  "${CONTEXT_DIR}"

echo "✅ Image ${IMAGE_NAME}:${IMAGE_TAG} successfully built."
