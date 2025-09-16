## Repository Information
- **FIPS Binaries Source (Primary)**: https://storage.googleapis.com/spectro-fips-binaries
- **FIPS Binaries Source (Additional)**: https://storage.googleapis.com/spectro-fips
- **Project**: Kubernetes Container (SpectroCloud)

## Successfully Migrated to FIPS Binaries

The following components have been successfully migrated to use FIPS binaries from the `spectro-fips-binaries` and `spectro-fips` repositories:

### Kubernetes Core Components
- **kube-apiserver** - Available in FIPS repository
- **kube-controller-manager** - Available in FIPS repository  
- **kube-scheduler** - Available in FIPS repository
- **kubelet** - Available in FIPS repository
- **kubectl** - Available in FIPS repository
- **kubeadm** - Available in FIPS repository
- **kube-proxy** - Available in FIPS repository

### CNI Plugins
- **bandwidth** - Available in FIPS repository (versions 1.1.1, 1.2.0, 1.3.0)
- **bridge** - Available in FIPS repository
- **dhcp** - Available in FIPS repository
- **firewall** - Available in FIPS repository
- **host-device** - Available in FIPS repository
- **host-local** - Available in FIPS repository
- **ipvlan** - Available in FIPS repository
- **loopback** - Available in FIPS repository
- **macvlan** - Available in FIPS repository
- **portmap** - Available in FIPS repository
- **ptp** - Available in FIPS repository
- **sbr** - Available in FIPS repository
- **static** - Available in FIPS repository
- **tuning** - Available in FIPS repository
- **vlan** - Available in FIPS repository
- **vrf** - Available in FIPS repository

### Container Runtime Components
- **containerd** - Available in FIPS repository (spectro-fips)
- **runc** - Available in FIPS repository (spectro-fips)
- **crictl** - Available in FIPS repository (spectro-fips)

## ❌ Still Using Standard (Non-FIPS) Sources

The following components are **NOT YET AVAILABLE** in the FIPS repository and continue to use standard sources:

### Control Plane Components
- **helm** - Currently using get.helm.sh
- **etcd** - Currently using GitHub releases
- **kine** - Currently using GitHub releases
- **konnectivity-server** - Currently using Docker registry

### Networking Components
- **vcluster-tunnel (tailscaled)** - Currently using GitHub releases

## 🔧 Changes Made

### 1. Updated `hack/download.sh`
- Modified Kubernetes core component downloads to use FIPS binaries
- Updated CNI plugin downloads to use individual FIPS binaries
- Added comments indicating which components are still using standard sources
- Maintained backward compatibility for non-FIPS components

### 2. Updated `hack/Dockerfile`
- Added comments to distinguish between FIPS and non-FIPS binaries
- No functional changes required as the binary names remain the same

## 🚀 Usage

The updated scripts will automatically use FIPS binaries where available and fall back to standard sources for components not yet available in the FIPS repository.

### Building with FIPS Components
```bash
# Download FIPS binaries (where available)
./hack/download.sh --kubernetes-version v1.31.7 --control-plane

# Build container with FIPS components
docker build -f hack/Dockerfile -t kubernetes-fips:v1.31.7 .
```