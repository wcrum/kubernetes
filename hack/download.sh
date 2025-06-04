# Default versions
KUBERNETES_VERSION=""
CNI_BINARIES_VERSION="v1.6.0"
CONTAINERD_VERSION=""
RUNC_VERSION=""
CRICTL_VERSION="v1.33.0"
HELM_VERSION=""
ETCD_VERSION=""
KINE_VERSION=""
KONNECTIVITY_VERSION="v0.32.0"
CONTROL_PLANE=false
TARGETARCH="amd64"

# Parse command line arguments
while [ $# -gt 0 ]; do
  case "$1" in
    --kubernetes-version)
      KUBERNETES_VERSION="$2"
      shift 2
      ;;
    --target-arch)
      TARGETARCH="$2"
      shift 2
      ;;
    --cni-binaries-version)
      CNI_BINARIES_VERSION="$2"
      shift 2
      ;;
    --containerd-version)
      CONTAINERD_VERSION="$2"
      shift 2
      ;;
    --runc-version)
      RUNC_VERSION="$2"
      shift 2
      ;;
    --crictl-version)
      CRICTL_VERSION="$2"
      shift 2
      ;;
    --etcd-version)
      ETCD_VERSION="$2"
      shift 2
      ;;
    --helm-version)
      HELM_VERSION="$2"
      shift 2
      ;;
    --kine-version)
      KINE_VERSION="$2"
      shift 2
      ;;
    --konnektivity-version)
      KONNEKTIVITY_VERSION="$2"
      shift 2
      ;;
    --control-plane)
      CONTROL_PLANE=true
      shift 1
      ;;
    *)
      echo "Unknown argument: $1"
      echo "Usage: $0 --kubernetes-version <version> [--cni-binaries-version <version>] [--containerd-version <version>] [--runc-version <version>] [--crictl-version <version>]"
      exit 1
      ;;
  esac
done

# Kubernetes version is required
if [ -z "$KUBERNETES_VERSION" ]; then
  echo "Error: --kubernetes-version is required"
  echo "Usage: $0 --kubernetes-version <version> [--cni-binaries-version <version>] [--containerd-version <version>] [--runc-version <version>] [--crictl-version <version>]"
  exit 1
fi

# containerd version
if [ -z "$CONTAINERD_VERSION" ]; then
  # cache in a file versions/containerd.txt
  mkdir -p ./versions
  if [ -f "./versions/containerd.txt" ]; then
    CONTAINERD_VERSION=$(cat ./versions/containerd.txt)
  else
    # trim the v from the version
    CONTAINERD_VERSION=$(curl -s "https://api.github.com/repos/containerd/containerd/releases/latest" | jq -r .tag_name | sed -E 's/^v//')
    echo $CONTAINERD_VERSION > ./versions/containerd.txt
  fi
fi

# runc version
if [ -z "$RUNC_VERSION" ]; then
  # cache in a file versions/runc.txt
  mkdir -p ./versions
  if [ -f "./versions/runc.txt" ]; then
    RUNC_VERSION=$(cat ./versions/runc.txt)
  else
    # trim the v from the version
    RUNC_VERSION=$(curl -s "https://api.github.com/repos/opencontainers/runc/releases/latest" | jq -r .tag_name)
    echo $RUNC_VERSION > ./versions/runc.txt
  fi
fi

# helm version
if [ -z "$HELM_VERSION" ]; then
  # cache in a file versions/helm.txt
  mkdir -p ./versions
  if [ -f "./versions/helm.txt" ]; then
    HELM_VERSION=$(cat ./versions/helm.txt)
  else
    # trim the v from the version
    HELM_VERSION=$(curl -s "https://api.github.com/repos/helm/helm/releases/latest" | jq -r .tag_name)
    echo $HELM_VERSION > ./versions/helm.txt
  fi
fi

# etcd version
if [ -z "$ETCD_VERSION" ]; then
  # cache in a file versions/etcd.txt
  mkdir -p ./versions
  if [ -f "./versions/etcd.txt" ]; then
    ETCD_VERSION=$(cat ./versions/etcd.txt)
  else
    # trim the v from the version
    ETCD_VERSION=$(curl -s "https://api.github.com/repos/etcd-io/etcd/releases/latest" | jq -r .tag_name)
    echo $ETCD_VERSION > ./versions/etcd.txt
  fi
fi

# kine version
if [ -z "$KINE_VERSION" ]; then
  # cache in a file versions/kine.txt
  mkdir -p ./versions
  if [ -f "./versions/kine.txt" ]; then
    KINE_VERSION=$(cat ./versions/kine.txt)
  else
    # trim the v from the version
    KINE_VERSION=$(curl -s "https://api.github.com/repos/k3s-io/kine/releases/latest" | jq -r .tag_name)
    echo $KINE_VERSION > ./versions/kine.txt
  fi
fi

# Trim kubernetes patch version to check if there is a file with that name
KUBERNETES_VERSION_TRIMMED=$(echo ${KUBERNETES_VERSION} | sed -E 's/^(v[0-9]+\.[0-9]+)\.[0-9]+$/\1/')
if [ -f "./kubernetes-${KUBERNETES_VERSION_TRIMMED}" ]; then
  # load the versions from the file
  source ./kubernetes-${KUBERNETES_VERSION_TRIMMED}
fi

# Create the directory for the binaries
mkdir -p ./release

# Download kubeadm, kubelet, and kubectl
echo "Downloading kubeadm ${KUBERNETES_VERSION}..."
curl -s -L -o kubeadm https://dl.k8s.io/release/${KUBERNETES_VERSION}/bin/linux/${TARGETARCH}/kubeadm
chmod +x kubeadm
mv kubeadm ./release/kubeadm
echo "Downloading kubelet ${KUBERNETES_VERSION}..."
curl -s -L -o kubelet https://dl.k8s.io/release/${KUBERNETES_VERSION}/bin/linux/${TARGETARCH}/kubelet
chmod +x kubelet
mv kubelet ./release/kubelet
echo "Downloading kubectl ${KUBERNETES_VERSION}..."
curl -s -L -o kubectl https://dl.k8s.io/release/${KUBERNETES_VERSION}/bin/linux/${TARGETARCH}/kubectl
chmod +x kubectl
mv kubectl ./release/kubectl

# Install CNI plugins
echo "Downloading CNI plugins ${CNI_BINARIES_VERSION}..."
curl -s -L -o cni.tgz https://github.com/containernetworking/plugins/releases/download/${CNI_BINARIES_VERSION}/cni-plugins-linux-${TARGETARCH}-${CNI_BINARIES_VERSION}.tgz
mkdir cni
tar -zxf cni.tgz -C cni
mkdir -p ./release/cni/bin
mv cni/loopback ./release/cni/bin
mv cni/portmap ./release/cni/bin
mv cni/bandwidth ./release/cni/bin
mv cni/bridge ./release/cni/bin
mv cni/firewall ./release/cni/bin
mv cni/host-local ./release/cni/bin
rm cni.tgz
rm -rf cni

# Download containerd & runc
echo "Downloading containerd ${CONTAINERD_VERSION}..."
curl -s -L -o containerd.tgz https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION}-linux-${TARGETARCH}.tar.gz
tar -zxf containerd.tgz bin
chmod +x bin/containerd-shim-runc-v2
mv bin/containerd-shim-runc-v2 ./release/containerd-shim-runc-v2
chmod +x bin/containerd
mv bin/containerd ./release/containerd
chmod +x bin/ctr
mv bin/ctr ./release/ctr
rm containerd.tgz
rm -rf bin
echo "Downloading runc ${RUNC_VERSION}..."
curl -s -L -o runc https://github.com/opencontainers/runc/releases/download/${RUNC_VERSION}/runc.${TARGETARCH}
chmod +x runc
mv runc ./release/runc

# Download crictl
echo "Downloading crictl ${CRICTL_VERSION}..."
curl -s -L https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-${TARGETARCH}.tar.gz --output crictl-${CRICTL_VERSION}-linux-${TARGETARCH}.tar.gz
tar -zxf crictl-${CRICTL_VERSION}-linux-${TARGETARCH}.tar.gz -C ./release
rm -f crictl-${CRICTL_VERSION}-linux-${TARGETARCH}.tar.gz

# Pack the release folder into a tar.gz file
echo "Packing the release folder into kubernetes-${KUBERNETES_VERSION}-${TARGETARCH}.tar.gz..."
tar -zcf kubernetes-${KUBERNETES_VERSION}-${TARGETARCH}.tar.gz ./release

# Write the notes to a file
cat <<EOF > ./kubernetes-${KUBERNETES_VERSION}.txt
This release contains required node binaries for Kubernetes ${KUBERNETES_VERSION}.

For more details on what's new, see the [Kubernetes release notes](https://github.com/kubernetes/kubernetes/releases/tag/${KUBERNETES_VERSION}).

## Component Versions
| Component | Version |
|---|---|
| Kubeadm | [${KUBERNETES_VERSION}](https://github.com/kubernetes/kubernetes/releases/tag/${KUBERNETES_VERSION}) |
| Kubelet | [${KUBERNETES_VERSION}](https://github.com/kubernetes/kubernetes/releases/tag/${KUBERNETES_VERSION}) |
| Kubectl | [${KUBERNETES_VERSION}](https://github.com/kubernetes/kubernetes/releases/tag/${KUBERNETES_VERSION}) |
| CNI Binaries | [${CNI_BINARIES_VERSION}](https://github.com/containernetworking/plugins/releases/tag/${CNI_BINARIES_VERSION}) |
| Containerd | [v${CONTAINERD_VERSION}](https://github.com/containerd/containerd/releases/tag/v${CONTAINERD_VERSION}) |
| Runc | [${RUNC_VERSION}](https://github.com/opencontainers/runc/releases/tag/${RUNC_VERSION}) |
| Crictl | [${CRICTL_VERSION}](https://github.com/kubernetes-sigs/cri-tools/releases/tag/${CRICTL_VERSION}) |
EOF

# delete the release folder
rm -rf ./release

# Download the control plane binaries if the control plane flag is true
if [ "$CONTROL_PLANE" = true ]; then
    # Create the directory for the control plane binaries
    mkdir -p ./release
    rm -f ./kubernetes-${KUBERNETES_VERSION}.txt

    # Download kube-apiserver
    echo "Downloading kube-apiserver ${KUBERNETES_VERSION}..."
    curl -s -L -o kube-apiserver https://dl.k8s.io/release/${KUBERNETES_VERSION}/bin/linux/${TARGETARCH}/kube-apiserver
    chmod +x kube-apiserver
    mv kube-apiserver ./release/kube-apiserver
    echo "Downloading kube-controller-manager ${KUBERNETES_VERSION}..."
    curl -s -L -o kube-controller-manager https://dl.k8s.io/release/${KUBERNETES_VERSION}/bin/linux/${TARGETARCH}/kube-controller-manager
    chmod +x kube-controller-manager
    mv kube-controller-manager ./release/kube-controller-manager
    echo "Downloading kube-scheduler ${KUBERNETES_VERSION}..."
    curl -s -L -o kube-scheduler https://dl.k8s.io/release/${KUBERNETES_VERSION}/bin/linux/${TARGETARCH}/kube-scheduler
    chmod +x kube-scheduler
    mv kube-scheduler ./release/kube-scheduler

    # Install helm
    echo "Downloading helm ${HELM_VERSION}..."
    curl -s -L -o helm3.tar.gz https://get.helm.sh/helm-${HELM_VERSION}-linux-${TARGETARCH}.tar.gz
    tar -zxf helm3.tar.gz linux-${TARGETARCH}/helm
    chmod +x linux-${TARGETARCH}/helm
    mv linux-${TARGETARCH}/helm ./release/helm
    rm helm3.tar.gz
    rm -R linux-${TARGETARCH}

    # Install etcd
    echo "Downloading etcd ${ETCD_VERSION}..."
    curl -s -L -o ./etcd-${ETCD_VERSION}-linux-${TARGETARCH}.tar.gz https://github.com/etcd-io/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-${TARGETARCH}.tar.gz
    mkdir -p ./etcd
    tar xzf ./etcd-${ETCD_VERSION}-linux-${TARGETARCH}.tar.gz -C ./etcd --strip-components=1 --no-same-owner
    rm -f ./etcd-${ETCD_VERSION}-linux-${TARGETARCH}.tar.gz
    chmod +x ./etcd/etcd
    chmod +x ./etcd/etcdctl
    mv ./etcd/etcd ./release/etcd
    mv ./etcd/etcdctl ./release/etcdctl
    rm -R ./etcd

    # Install kine
    echo "Downloading kine ${KINE_VERSION}..."
    curl -s -L -o kine https://github.com/k3s-io/kine/releases/download/${KINE_VERSION}/kine-${TARGETARCH}
    chmod +x kine
    mv kine ./release/kine

    # Install konnektivity
    echo "Downloading konnektivity ${KONNECTIVITY_VERSION}..."
    docker pull --platform linux/${TARGETARCH} registry.k8s.io/kas-network-proxy/proxy-server:${KONNECTIVITY_VERSION}
    KONNECTIVITY_DOCKER_CONTAINER=$(docker create --platform linux/${TARGETARCH} registry.k8s.io/kas-network-proxy/proxy-server:${KONNECTIVITY_VERSION})
    docker cp ${KONNECTIVITY_DOCKER_CONTAINER}:/proxy-server ./release/konnectivity-server
    docker rm ${KONNECTIVITY_DOCKER_CONTAINER}

    # Move the agent binaries
    mv ./kubernetes-${KUBERNETES_VERSION}-${TARGETARCH}.tar.gz ./release/kubernetes-${KUBERNETES_VERSION}-${TARGETARCH}.tar.gz

    # Pack the kubernetes-${KUBERNETES_VERSION}-${TARGETARCH}-control-plane.tar.gz
    echo "Packing the control plane folder into kubernetes-${KUBERNETES_VERSION}-${TARGETARCH}-full.tar.gz..."
    tar -zcf kubernetes-${KUBERNETES_VERSION}-${TARGETARCH}-full.tar.gz ./release

    # delete the release folder
    rm -rf ./release
fi