# Kubernetes Container

This project provides a unified container image that bundles the core Kubernetes control plane components (kube-apiserver, kube-controller-manager, and kube-scheduler) into a single, lightweight Alpine-based image.

## Overview

The Kubernetes Control Plane Container offers:

- **Unified packaging**: All core control plane components in one container
- **Multi-architecture support**: Built for both `linux/amd64` and `linux/arm64`
- **Version tracking**: Automated daily builds for all stable Kubernetes releases
- **Minimal footprint**: Based on Alpine Linux for a smaller image size
- **Non-root execution**: Runs as a non-privileged user for enhanced security

## Available Images

Images are published to the GitHub Container Registry:

```
ghcr.io/loft-sh/kubernetes:v1.x.y
```

Where `v1.x.y` corresponds to the Kubernetes version.

## Usage

You can pull the image using:

```bash
docker pull ghcr.io/loft-sh/kubernetes:v1.28.0
```

## Building Locally

### Prerequisites

- Docker with buildx support
- Make

### Build Commands

Build the image locally:

```bash
make build
```

Build for a specific Kubernetes version:

```bash
make build K8S_VERSION=v1.29.0
```

Push to a registry:

```bash
make push REGISTRY=myregistry.io/ IMAGE_NAME=kubernetes
```

## Configuration Options

The build process can be customized with the following variables:

| Variable | Description | Default |
|----------|-------------|---------|
| K8S_VERSION | Kubernetes version to build | v1.28.0 |
| PLATFORMS | Target architectures | linux/amd64,linux/arm64 |
| IMAGE_NAME | Name of the container image | kubernetes-control-plane |
| REGISTRY | Container registry prefix | (empty) |

## Automated Builds

A GitHub Actions workflow runs daily to:

1. Identify all stable Kubernetes releases
2. Check for missing versions in the container registry
3. Automatically build and push images for any missing versions

## Maintainer

This project is maintained by [Loft Labs Inc](https://loft.sh)
