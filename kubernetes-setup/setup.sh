#!/bin/bash

set -e  # Exit immediately if any command fails

echo "=============================="
echo " Kubernetes KIND Full Setup "
echo "=============================="

# -----------------------------
# 1. Update system
# -----------------------------
echo "[1/7] Updating system packages..."
sudo apt update -y && sudo apt upgrade -y

# -----------------------------
# 2. Install required packages
# -----------------------------
echo "[2/7] Installing basic dependencies..."
sudo apt install -y \
  ca-certificates \
  curl \
  wget \
  gnupg \
  lsb-release \
  apt-transport-https \
  software-properties-common

# -----------------------------
# 3. Install Docker
# -----------------------------
echo "[3/7] Installing Docker..."
if ! command -v docker &> /dev/null; then
  curl -fsSL https://get.docker.com | sudo bash
  sudo usermod -aG docker $USER
  echo "Docker installed. Please LOGOUT & LOGIN again after script completes."
else
  echo "Docker already installed."
fi

# Enable Docker on boot
sudo systemctl enable docker
sudo systemctl start docker

# -----------------------------
# 4. Install kubectl
# -----------------------------
echo "[4/7] Installing kubectl..."
if ! command -v kubectl &> /dev/null; then
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
else
  echo "kubectl already installed."
fi

# Enable kubectl bash completion
echo "source <(kubectl completion bash)" >> ~/.bashrc

# -----------------------------
# 5. Install KIND
# -----------------------------
echo "[5/7] Installing KIND..."
if ! command -v kind &> /dev/null; then
  curl -Lo kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64
  chmod +x kind
  sudo mv kind /usr/local/bin/
else
  echo "KIND already installed."
fi



# -----------------------------
# 7. Verify installations
# -----------------------------
echo "[7/7] Verifying installations..."
docker --version
kubectl version --client
kind version
helm version

echo "========================================"
echo " KIND Kubernetes setup completed ✅"
echo ""
echo " NEXT STEPS:"
echo " 1. Logout & login (important for Docker)"
echo " 2. Create cluster:"
echo "      kind create cluster --name dev-cluster"
echo " 3. Test:"
echo "      kubectl get nodes"
echo "========================================"
