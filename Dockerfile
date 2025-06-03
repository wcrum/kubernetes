# Multi-stage build to extract Kubernetes control plane binaries
ARG K8S_VERSION=v1.28.0
ARG TARGETARCH
FROM registry.k8s.io/kube-apiserver:${K8S_VERSION} as apiserver
FROM registry.k8s.io/kube-controller-manager:${K8S_VERSION} as controller
FROM registry.k8s.io/kube-scheduler:${K8S_VERSION} as scheduler

# Final Alpine-based image
FROM alpine:3.18

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
COPY --from=apiserver --chown=kubernetes:kubernetes --chmod=0755 /usr/local/bin/kube-apiserver /kubernetes/
COPY --from=controller --chown=kubernetes:kubernetes --chmod=0755 /usr/local/bin/kube-controller-manager /kubernetes/
COPY --from=scheduler --chown=kubernetes:kubernetes --chmod=0755 /usr/local/bin/kube-scheduler /kubernetes/
COPY --chown=kubernetes:kubernetes ./kubernetes-*-amd64.tar.gz /kubernetes/
COPY --chown=kubernetes:kubernetes ./kubernetes-*-arm64.tar.gz /kubernetes/

# Set up the container
WORKDIR /
USER kubernetes
