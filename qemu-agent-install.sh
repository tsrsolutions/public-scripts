#!/bin/bash

set -e  # Exit on any error

echo "Installing QEMU Guest Agent..."

# Detect OS and install
if [ -f /etc/debian_version ]; then
    # Debian/Ubuntu
    apt-get update
    apt-get install -y qemu-guest-agent
elif [ -f /etc/redhat-release ]; then
    # RHEL/CentOS/Rocky/Alma
    yum install -y qemu-guest-agent
elif [ -f /etc/arch-release ]; then
    # Arch Linux
    pacman -Sy --noconfirm qemu-guest-agent
else
    echo "Unsupported distribution"
    exit 1
fi

echo "Starting QEMU Guest Agent..."
systemctl start qemu-guest-agent

echo "Verifying service is running..."
if systemctl is-active --quiet qemu-guest-agent; then
    echo "✓ QEMU Guest Agent is running"
    systemctl status qemu-guest-agent --no-pager
else
    echo "✗ Failed to start QEMU Guest Agent"
    exit 1
fi

echo ""
echo "Installation complete! The agent will start automatically on future boots."