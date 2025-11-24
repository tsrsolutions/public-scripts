#!/bin/bash
set -e

# Docker Installation Script for Linux (Ubuntu/Debian)
# Usage: curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/install-docker.sh | bash

echo "================================================"
echo "Docker Installation Script"
echo "================================================"

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "Please do not run this script as root. Run as a regular user with sudo privileges."
    exit 1
fi

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION=$VERSION_ID
else
    echo "Cannot detect OS. This script supports Ubuntu/Debian-based systems."
    exit 1
fi

echo "Detected OS: $OS $VERSION"

# Check if Docker is already installed
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    echo "Docker is already installed: $DOCKER_VERSION"
    read -p "Do you want to continue and reinstall? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

# Update package index
echo "Updating package index..."
sudo apt-get update

# Install prerequisites
echo "Installing prerequisites..."
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
echo "Adding Docker's official GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/$OS/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Set up the Docker repository
echo "Setting up Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$OS \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index again
echo "Updating package index with Docker repository..."
sudo apt-get update

# Install Docker Engine
echo "Installing Docker Engine..."
sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# Start and enable Docker service
echo "Starting Docker service..."
sudo systemctl start docker
sudo systemctl enable docker

# Add current user to docker group
echo "Adding current user ($USER) to docker group..."
sudo usermod -aG docker $USER

# Verify installation
echo ""
echo "================================================"
echo "Docker Installation Complete!"
echo "================================================"
docker --version
echo ""
echo "Docker Compose version:"
docker compose version
echo ""
echo "⚠️  IMPORTANT: You need to log out and log back in for group changes to take effect."
echo "   Alternatively, run: newgrp docker"
echo ""
echo "To verify Docker is working, run: docker run hello-world"
echo "================================================"
