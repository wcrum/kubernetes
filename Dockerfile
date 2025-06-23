# Multi-stage build to extract Kubernetes control plane binaries
ARG K8S_VERSION=v1.28.0

# Final Alpine-based image
FROM alpine:3.18
ARG TARGETARCH

LABEL maintainer="Loft Labs Inc <support@loft.sh>"
LABEL description="Kubernetes control plane components (apiserver, controller-manager, scheduler)"
LABEL version="${K8S_VERSION}"

# Install necessary packages
RUN apk --no-cache add \
      ca-certificates bash curl tzdata \
    && addgroup -g 1000 kubernetes \
    && adduser -D -u 1000 -G kubernetes kubernetes \
    && mkdir -p /kubernetes \
    && chown -R kubernetes:kubernetes /kubernetes

# Copy binaries from each component
COPY --chown=kubernetes:kubernetes ./kube-apiserver-${TARGETARCH} /kubernetes/kube-apiserver
COPY --chown=kubernetes:kubernetes ./kube-controller-manager-${TARGETARCH} /kubernetes/kube-controller-manager
COPY --chown=kubernetes:kubernetes ./kube-scheduler-${TARGETARCH} /kubernetes/kube-scheduler
COPY --chown=kubernetes:kubernetes ./kubernetes-*-amd64.tar.gz /kubernetes/
COPY --chown=kubernetes:kubernetes ./kubernetes-*-arm64.tar.gz /kubernetes/

# Set up the container
WORKDIR /
USER kubernetes
