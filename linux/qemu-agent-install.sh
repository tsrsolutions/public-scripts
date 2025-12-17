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

# Check if already running
if systemctl is-active --quiet qemu-guest-agent; then
    echo "QEMU Guest Agent is already running"
    systemctl status qemu-guest-agent --no-pager -l
    echo ""
    echo "Installation complete! The agent is running and will start automatically on future boots."
    exit 0
fi

# Enable and start the service
# Some distros use socket activation (qemu-guest-agent.socket), others use the service directly
# Try socket first, then fall back to service
echo "Enabling QEMU Guest Agent..."

if systemctl list-unit-files qemu-guest-agent.socket &>/dev/null && \
   systemctl list-unit-files qemu-guest-agent.socket | grep -q qemu-guest-agent.socket; then
    # Socket activation available - enable and start the socket
    if ! systemctl is-enabled --quiet qemu-guest-agent.socket 2>/dev/null; then
        systemctl enable qemu-guest-agent.socket 2>/dev/null || true
    fi
    systemctl start qemu-guest-agent.socket 2>/dev/null || true
fi

# Try to enable the service directly (works on RHEL-based distros)
# Use is-enabled check first to avoid errors on systems using socket activation
if systemctl is-enabled --quiet qemu-guest-agent 2>/dev/null; then
    echo "Service is already enabled"
elif systemctl enable qemu-guest-agent 2>/dev/null; then
    echo "Service enabled successfully"
else
    # Service may use socket activation or static enablement - not an error
    echo "Note: Service uses socket/static activation (this is normal)"
fi

echo "Starting QEMU Guest Agent..."
systemctl start qemu-guest-agent 2>/dev/null || true

echo "Verifying service is running..."
if systemctl is-active --quiet qemu-guest-agent; then
    echo "QEMU Guest Agent is running"
    systemctl status qemu-guest-agent --no-pager -l
else
    echo "Failed to start QEMU Guest Agent"
    exit 1
fi

echo ""
echo "Installation complete! The agent will start automatically on future boots."