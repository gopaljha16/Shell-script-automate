#!/bin/bash

set -e  # agar koi command fail ho jaaye to script ruk jaaye

echo "=============================="
echo " Docker Full Setup Starting "
echo "=============================="

# -----------------------------
# 1. System update
# -----------------------------
echo "[1/5] Updating system..."
sudo apt update -y && sudo apt upgrade -y

# -----------------------------
# 2. Install dependencies
# -----------------------------
echo "[2/5] Installing dependencies..."
sudo apt install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  apt-transport-https \
  software-properties-common

# -----------------------------
# 3. Install Docker Engine
# -----------------------------
echo "[3/5] Installing Docker..."
if ! command -v docker &> /dev/null; then
  curl -fsSL https://get.docker.com | sudo bash
else
  echo "Docker already installed."
fi

# -----------------------------
# 4. Docker service & permissions
# -----------------------------
echo "[4/5] Configuring Docker..."
sudo systemctl enable docker
sudo systemctl start docker

# Add current user to docker group (NO sudo needed later)
sudo usermod -aG docker $USER

# -----------------------------
# 5. Verify installation
# -----------------------------
echo "[5/5] Verifying Docker..."
docker --version
docker info | grep -i "Server Version"

echo "========================================"
echo " Docker installation completed ✅"
echo ""
echo " ⚠️ IMPORTANT:"
echo " Logout & Login once to apply docker group"
echo ""
echo " Test after login:"
echo "   docker run hello-world"
echo "========================================"
