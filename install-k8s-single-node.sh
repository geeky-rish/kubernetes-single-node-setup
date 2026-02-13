#!/bin/bash

set -e

echo "========================================"
echo " Single Node Kubernetes Setup Script"
echo " Ubuntu 22.04 | kubeadm | Calico"
echo "========================================"

# Must be root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (sudo -i)"
  exit 1
fi


# ----------------------------------------
# Disable Swap
# ----------------------------------------
echo "[1/10] Disabling swap..."

swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab


# ----------------------------------------
# System Update
# ----------------------------------------
echo "[2/10] Updating system..."

apt update && apt upgrade -y


# ----------------------------------------
# Install Docker & Containerd
# ----------------------------------------
echo "[3/10] Installing Docker & Containerd..."

apt install -y ca-certificates curl gnupg lsb-release

mkdir -p /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
| gpg --dearmor -o /etc/apt/keyrings/docker.gpg


echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu jammy stable" \
> /etc/apt/sources.list.d/docker.list


apt update

apt install -y docker-ce docker-ce-cli containerd.io

systemctl enable docker
systemctl start docker


# ----------------------------------------
# Configure Containerd
# ----------------------------------------
echo "[4/10] Configuring containerd..."

mkdir -p /etc/containerd

containerd config default > /etc/containerd/config.toml

sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' \
/etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd


# ----------------------------------------
# Install Kubernetes Components
# ----------------------------------------
echo "[5/10] Installing Kubernetes..."

mkdir -p /etc/apt/keyrings

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key \
| gpg --dearmor -o /etc/apt/keyrings/kubernetes.gpg


echo \
"deb [signed-by=/etc/apt/keyrings/kubernetes.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" \
> /etc/apt/sources.list.d/kubernetes.list


apt update

apt install -y kubelet kubeadm kubectl

apt-mark hold kubelet kubeadm kubectl


# ----------------------------------------
# Kernel Networking
# ----------------------------------------
echo "[6/10] Configuring kernel networking..."

modprobe br_netfilter


cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF


sysctl --system


# ----------------------------------------
# Initialize Cluster
# ----------------------------------------
echo "[7/10] Initializing Kubernetes..."

kubeadm init --pod-network-cidr=192.168.0.0/16


# ----------------------------------------
# Configure kubectl
# ----------------------------------------
echo "[8/10] Configuring kubectl..."

mkdir -p $HOME/.kube

cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

chown $(id -u):$(id -g) $HOME/.kube/config


# ----------------------------------------
# Install Calico
# ----------------------------------------
echo "[9/10] Installing Calico..."

kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml


# ----------------------------------------
# Remove Control Plane Taint (Single Node)
# ----------------------------------------
echo "[10/10] Allowing workloads on control plane..."

kubectl taint nodes --all node-role.kubernetes.io/control-plane- || true


echo "========================================"
echo " Kubernetes Installation Complete!"
echo "========================================"

echo ""
echo "Wait 2 minutes, then run:"
echo "kubectl get nodes"
echo "kubectl get pods -n kube-system"
echo ""
echo "Then deploy apps."
echo ""

