#!/bin/bash
set -e

# Claude Code Installation Script for macOS and Linux
# Uses the official Anthropic installer
# Usage: curl -sSL https://raw.githubusercontent.com/tsrsolutions/public-scripts/main/install-claude-code.sh | bash

echo "================================================"
echo "Claude Code Installation Script"
echo "================================================"

# Detect OS
case "$(uname -s)" in
    Darwin)
        echo "Detected OS: macOS"
        ;;
    Linux)
        echo "Detected OS: Linux"
        ;;
    *)
        echo "Unsupported operating system: $(uname -s)"
        echo "This script supports macOS and Linux only."
        exit 1
        ;;
esac

# Check if Claude Code is already installed
if command -v claude &> /dev/null; then
    CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "unknown")
    echo "Claude Code is already installed: $CLAUDE_VERSION"
    read -p "Do you want to continue and reinstall/upgrade? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

# Run the official Anthropic installer
echo ""
echo "Running official Claude Code installer..."
echo ""

curl -fsSL https://claude.ai/install.sh | bash

echo ""
echo "================================================"
echo "Claude Code Installation Complete!"
echo "================================================"

if command -v claude &> /dev/null; then
    echo "Claude Code version:"
    claude --version
    echo ""
    echo "To get started, run: claude"
else
    echo "Installation completed. You may need to restart your terminal"
    echo "or source your shell profile for the 'claude' command to be available."
fi

echo "================================================"
