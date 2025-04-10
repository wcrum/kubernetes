# Default values
K8S_VERSION ?= v1.28.0
PLATFORMS ?= linux/amd64,linux/arm64
IMAGE_NAME ?= kubernetes-control-plane
IMAGE_TAG ?= $(K8S_VERSION)
REGISTRY ?= 

# Build the Docker image with multi-platform support
build:
	docker buildx build \
		--build-arg K8S_VERSION=$(K8S_VERSION) \
		--platform $(PLATFORMS) \
		-t $(REGISTRY)$(IMAGE_NAME):$(IMAGE_TAG) \
		--push=false \
		.

# Push the Docker image to a registry
push: 
	docker buildx build \
		--build-arg K8S_VERSION=$(K8S_VERSION) \
		--platform $(PLATFORMS) \
		-t $(REGISTRY)$(IMAGE_NAME):$(IMAGE_TAG) \
		--push \
		.

# Clean up
clean:
	docker rmi $(REGISTRY)$(IMAGE_NAME):$(IMAGE_TAG) || true

# Help target
help:
	@echo "Available targets:"
	@echo "  build        - Build multi-platform container image (K8S_VERSION=v1.28.0)"
	@echo "  push         - Build and push multi-platform container image"
	@echo "  clean        - Remove built images"
	@echo ""
	@echo "Examples:"
	@echo "  make build K8S_VERSION=v1.29.0"
	@echo "  make push REGISTRY=myregistry.io/ IMAGE_NAME=k8s-control-plane"
	@echo "  make build PLATFORMS=linux/amd64"

.PHONY: build push clean help
