# Public Scripts

A collection of utility scripts for macOS and Linux setup and configuration.

## Available Scripts

### Claude Code Installation Script

Installs Claude Code (Anthropic's official CLI for Claude) on macOS and Linux systems using the official native installer.

**Supported Platforms:**
- macOS (Intel and Apple Silicon)
- Linux

**Features:**
- Uses the official Anthropic installer (no Node.js required)
- Auto-detects operating system
- Checks for existing installation before reinstalling
- Verifies successful installation

**Usage:**

Pipe directly to bash:
```bash
curl -sSL https://raw.githubusercontent.com/tsrsolutions/public-scripts/main/install-claude-code.sh | bash
```

Or download and run locally:
```bash
curl -sSL https://raw.githubusercontent.com/tsrsolutions/public-scripts/main/install-claude-code.sh -o install-claude-code.sh
chmod +x install-claude-code.sh
./install-claude-code.sh
```

**Post-Installation:**
After installation, start Claude Code by running:
```bash
claude
```

You'll be prompted to authenticate with your Anthropic API key or log in to your Anthropic account on first run.

---

### Docker Installation Script

Installs the latest stable version of Docker Engine on Ubuntu/Debian-based systems.

**Features:**
- Installs Docker Engine, CLI, containerd, buildx, and compose plugins
- Adds Docker's official GPG key and repository
- Configures Docker service to start automatically
- Adds the current user to the docker group
- Includes safety checks and error handling

**Usage:**

Pipe directly to bash:
```bash
curl -sSL https://raw.githubusercontent.com/tsrsolutions/public-scripts/main/install-docker.sh | bash
```

Or download and run locally:
```bash
curl -sSL https://raw.githubusercontent.com/tsrsolutions/public-scripts/main/install-docker.sh -o install-docker.sh
chmod +x install-docker.sh
./install-docker.sh
```

**Post-Installation:**
After installation, log out and log back in for docker group changes to take effect, or run:
```bash
newgrp docker
```

Verify installation:
```bash
docker run hello-world
```

---

### QEMU Guest Agent Installation Script

Installs and configures the QEMU Guest Agent on Linux VMs. The guest agent enables better integration between the VM and the hypervisor, providing improved monitoring and management capabilities.

**Supported Distributions:**
- Debian/Ubuntu
- RHEL/CentOS/Rocky/Alma Linux
- Arch Linux

**Features:**
- Auto-detects the Linux distribution
- Installs the appropriate package
- Handles both socket activation and direct service configurations
- Enables automatic startup on boot
- Verifies successful installation

**Usage:**

Pipe directly to bash (requires root):
```bash
curl -sSL https://raw.githubusercontent.com/tsrsolutions/public-scripts/main/qemu-agent-install.sh | sudo bash
```

Or download and run locally:
```bash
curl -sSL https://raw.githubusercontent.com/tsrsolutions/public-scripts/main/qemu-agent-install.sh -o qemu-agent-install.sh
chmod +x qemu-agent-install.sh
sudo ./qemu-agent-install.sh
```

---

## Requirements

- macOS or Linux-based operating system
- `curl` installed
- Appropriate privileges (sudo access for Linux package installation)
- Internet connection

## Security Considerations

Always review scripts before piping to bash. You can inspect any script by visiting:
```
https://raw.githubusercontent.com/tsrsolutions/public-scripts/main/<script-name>.sh
```

## Contributing

Feel free to submit issues or pull requests for improvements or additional scripts.

## License

These scripts are provided as-is for public use.
