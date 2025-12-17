# Public Scripts

A collection of utility scripts for macOS, Linux, and Windows setup and configuration.

## Directory Structure

```
├── linux/          # Linux-specific scripts
├── macos/          # macOS-specific scripts
└── windows/        # Windows-specific scripts (future)
```

## Available Scripts

### Claude Code Installation Script

**Location:** `linux/install-claude-code.sh` and `macos/install-claude-code.sh`

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

**Linux:**
```bash
curl -sSL https://raw.githubusercontent.com/tsrsolutions/public-scripts/main/linux/install-claude-code.sh | bash
```

**macOS:**
```bash
curl -sSL https://raw.githubusercontent.com/tsrsolutions/public-scripts/main/macos/install-claude-code.sh | bash
```

**Post-Installation:**
After installation, start Claude Code by running:
```bash
claude
```

You'll be prompted to authenticate with your Anthropic API key or log in to your Anthropic account on first run.

---

### Docker Installation Script

**Location:** `linux/install-docker.sh`

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
curl -sSL https://raw.githubusercontent.com/tsrsolutions/public-scripts/main/linux/install-docker.sh | bash
```

Or download and run locally:
```bash
curl -sSL https://raw.githubusercontent.com/tsrsolutions/public-scripts/main/linux/install-docker.sh -o install-docker.sh
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

**Location:** `linux/qemu-agent-install.sh`

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
curl -sSL https://raw.githubusercontent.com/tsrsolutions/public-scripts/main/linux/qemu-agent-install.sh | sudo bash
```

Or download and run locally:
```bash
curl -sSL https://raw.githubusercontent.com/tsrsolutions/public-scripts/main/linux/qemu-agent-install.sh -o qemu-agent-install.sh
chmod +x qemu-agent-install.sh
sudo ./qemu-agent-install.sh
```

---

### VirtIO Drivers Installation Script (Windows)

**Location:** `windows/Install-VirtioDrivers.ps1`

Downloads and installs VirtIO drivers and QEMU Guest Agent on Windows VMs running on QEMU/KVM hypervisors.

**Supported Platforms:**
- Windows 7/8/8.1/10/11
- Windows Server 2008 R2 through 2025

**Features:**
- Auto-detects Windows version and architecture
- Downloads VirtIO drivers ISO from official Fedora repository
- Installs appropriate drivers using driver metadata
- Installs QEMU Guest Agent and VirtIO guest tools
- Automatic cleanup of temporary files
- Support for both 32-bit and 64-bit systems

**Usage:**

**Option 1:** Run directly from PowerShell (Run as Administrator):
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; irm https://raw.githubusercontent.com/tsrsolutions/public-scripts/main/windows/Install-VirtioDrivers.ps1 | iex
```

**Option 2:** Download and run locally:
```powershell
# Download the script
Invoke-WebRequest -Uri https://raw.githubusercontent.com/tsrsolutions/public-scripts/main/windows/Install-VirtioDrivers.ps1 -OutFile Install-VirtioDrivers.ps1

# Run the script (as Administrator)
.\Install-VirtioDrivers.ps1
```

**Parameters:**
- `-SkipDrivers`: Skip driver installation, only install guest tools
- `-SkipGuestTools`: Skip guest tools installation, only install drivers
- `-IsoUrl <url>`: Use a custom ISO URL

**Post-Installation:**
A reboot may be required for all drivers to take effect.

---

## Requirements

**Linux/macOS:**
- `curl` installed
- Appropriate privileges (sudo access for package installation)
- Internet connection

**Windows:**
- PowerShell 5.0 or later
- Administrator privileges
- Internet connection

## Security Considerations

Always review scripts before running them. You can inspect any script by visiting:
```
https://raw.githubusercontent.com/tsrsolutions/public-scripts/main/<os>/<script-name>
```

## Contributing

Feel free to submit issues or pull requests for improvements or additional scripts.

## License

These scripts are provided as-is for public use.
