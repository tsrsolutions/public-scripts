<#
.SYNOPSIS
    Downloads and installs VirtIO drivers and Windows guest tools.

.DESCRIPTION
    Downloads the virtio-win ISO (if needed) and installs:
    - VirtIO Windows drivers using info.json metadata
    - QEMU Guest Agent / VirtIO guest tools

.PARAMETER IsoUrl
    URL to download the virtio-win ISO. Defaults to stable release.

.PARAMETER SkipDrivers
    Skip driver installation, only install guest tools.

.PARAMETER SkipGuestTools
    Skip guest tools installation, only install drivers.

.EXAMPLE
    # One-liner from PowerShell (Run as Administrator):
    irm https://raw.githubusercontent.com/USERNAME/REPO/main/Install-VirtioDrivers.ps1 | iex

.NOTES
    Must be run as Administrator.
    Source: https://github.com/virtio-win/virtio-win-pkg-scripts
#>

[CmdletBinding()]
param(
    [string]$IsoUrl = "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.271-1/virtio-win-0.1.271.iso",
    [switch]$SkipDrivers,
    [switch]$SkipGuestTools
)

# Check for Administrator privileges
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $IsAdmin) {
    Write-Host "[-] This script requires Administrator privileges." -ForegroundColor Red
    Write-Host "    Please run PowerShell as Administrator and try again." -ForegroundColor Yellow
    exit 1
}

$ErrorActionPreference = 'Stop'

function Write-Status {
    param([string]$Message)
    Write-Host "[*] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[+] $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[!] $Message" -ForegroundColor Yellow
}

function Write-Err {
    param([string]$Message)
    Write-Host "[-] $Message" -ForegroundColor Red
}

# Download ISO to temp directory
$IsoFileName = [System.IO.Path]::GetFileName($IsoUrl)
$IsoPath = Join-Path $env:TEMP $IsoFileName

Write-Status "Downloading VirtIO drivers ISO..."
Write-Status "URL: $IsoUrl"
Write-Status "Destination: $IsoPath"

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Use BITS for better download experience if available
    if (Get-Command Start-BitsTransfer -ErrorAction SilentlyContinue) {
        Start-BitsTransfer -Source $IsoUrl -Destination $IsoPath -Description "Downloading VirtIO drivers"
    }
    else {
        # Fallback to Invoke-WebRequest with progress
        $ProgressPreference = 'Continue'
        Invoke-WebRequest -Uri $IsoUrl -OutFile $IsoPath -UseBasicParsing
    }

    Write-Success "Download complete: $IsoPath"
}
catch {
    Write-Err "Failed to download ISO: $_"
    exit 1
}

Write-Status "Using ISO: $IsoPath"

# Determine Windows version mapping
function Get-VirtioWindowsVersion {
    $WinVer = [System.Environment]::OSVersion.Version
    $BuildNumber = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentBuildNumber

    # Windows Server / Client version detection
    $ProductType = (Get-CimInstance Win32_OperatingSystem).ProductType
    $IsServer = $ProductType -ne 1

    switch ($WinVer.Major) {
        10 {
            if ([int]$BuildNumber -ge 26100) { return "2k25" }      # Server 2025
            if ([int]$BuildNumber -ge 22000) {                       # Win11 / Server 2022
                return if ($IsServer) { "2k22" } else { "w11" }
            }
            if ([int]$BuildNumber -ge 17763) {                       # Win10 1809+ / Server 2019
                return if ($IsServer) { "2k19" } else { "w10" }
            }
            return if ($IsServer) { "2k16" } else { "w10" }
        }
        6 {
            switch ($WinVer.Minor) {
                3 { return if ($IsServer) { "2k12R2" } else { "w8.1" } }
                2 { return if ($IsServer) { "2k12" } else { "w8" } }
                1 { return if ($IsServer) { "2k8R2" } else { "w7" } }
                0 { return "2k8" }
            }
        }
        5 {
            return if ($WinVer.Minor -eq 2) { "2k3" } else { "xp" }
        }
    }
    return "2k22"  # Default fallback
}

# Mount ISO
Write-Status "Mounting ISO..."
try {
    $MountResult = Mount-DiskImage -ImagePath $IsoPath -PassThru
    $DriveLetter = ($MountResult | Get-Volume).DriveLetter
    $MountPath = "${DriveLetter}:"
    Write-Success "ISO mounted at $MountPath"
}
catch {
    Write-Err "Failed to mount ISO: $_"
    exit 1
}

try {
    # Detect architecture and Windows version
    $Arch = if ([Environment]::Is64BitOperatingSystem) { "amd64" } else { "x86" }
    $WinVer = Get-VirtioWindowsVersion

    Write-Status "Detected: Windows $WinVer, Architecture: $Arch"

    # Install drivers
    if (-not $SkipDrivers) {
        $InfoJsonPath = Join-Path $MountPath "data\info.json"

        if (Test-Path $InfoJsonPath) {
            Write-Status "Reading driver metadata from info.json..."
            $DriverInfo = Get-Content $InfoJsonPath -Raw | ConvertFrom-Json

            # Filter drivers for current OS and architecture
            $ApplicableDrivers = $DriverInfo.drivers | Where-Object {
                $_.windows_version -eq $WinVer -and $_.arch -eq $Arch
            }

            # Fallback: try w10 drivers if specific version not found
            if (-not $ApplicableDrivers -and $WinVer -notin @("w10", "2k19", "2k22")) {
                Write-Warn "No drivers for $WinVer, trying w10 drivers..."
                $ApplicableDrivers = $DriverInfo.drivers | Where-Object {
                    $_.windows_version -eq "w10" -and $_.arch -eq $Arch
                }
            }

            if ($ApplicableDrivers) {
                Write-Status "Found $($ApplicableDrivers.Count) drivers to install"

                $Installed = 0
                $Skipped = 0

                foreach ($Driver in $ApplicableDrivers) {
                    $InfPath = Join-Path $MountPath $Driver.inf_path

                    if (Test-Path $InfPath) {
                        Write-Status "Installing: $($Driver.name)"
                        try {
                            $Result = pnputil.exe /add-driver $InfPath /install 2>&1
                            if ($LASTEXITCODE -eq 0 -or $Result -match "successfully") {
                                Write-Success "  Installed: $($Driver.name)"
                                $Installed++
                            }
                            else {
                                Write-Warn "  Note: $($Driver.name) - may already be installed or not applicable"
                                $Skipped++
                            }
                        }
                        catch {
                            Write-Warn "  Skipped: $($Driver.name) - $_"
                            $Skipped++
                        }
                    }
                    else {
                        Write-Warn "  Driver file not found: $($Driver.inf_path)"
                        $Skipped++
                    }
                }

                Write-Success "Driver installation complete: $Installed installed, $Skipped skipped"
            }
            else {
                Write-Warn "No applicable drivers found for $WinVer $Arch"
            }
        }
        else {
            # Fallback: manually iterate driver folders if info.json missing
            Write-Warn "info.json not found, using fallback driver detection..."

            $DriverFolders = @(
                "viostor", "vioscsi", "NetKVM", "Balloon", "vioserial",
                "viorng", "vioinput", "pvpanic", "qxldod", "viogpudo",
                "viosock", "viofs", "viomem", "fwcfg", "sriov"
            )

            foreach ($Driver in $DriverFolders) {
                $DriverPath = Join-Path $MountPath "$Driver\$WinVer\$Arch"

                if (-not (Test-Path $DriverPath)) {
                    $DriverPath = Join-Path $MountPath "$Driver\w10\$Arch"
                }

                if (Test-Path $DriverPath) {
                    $InfFiles = Get-ChildItem -Path $DriverPath -Filter "*.inf" -ErrorAction SilentlyContinue
                    foreach ($Inf in $InfFiles) {
                        Write-Status "Installing: $Driver"
                        pnputil.exe /add-driver $Inf.FullName /install 2>&1 | Out-Null
                    }
                }
            }
        }
    }

    # Install Guest Tools
    if (-not $SkipGuestTools) {
        $GuestToolsExe = Join-Path $MountPath "virtio-win-guest-tools.exe"

        if (Test-Path $GuestToolsExe) {
            Write-Status "Installing VirtIO Guest Tools..."

            $Process = Start-Process -FilePath $GuestToolsExe -ArgumentList "/S" -Wait -PassThru

            if ($Process.ExitCode -eq 0) {
                Write-Success "VirtIO Guest Tools installed successfully"
            }
            else {
                Write-Warn "Guest tools installer exited with code: $($Process.ExitCode)"
            }
        }
        else {
            # Try MSI installer as fallback
            $MsiPath = if ($Arch -eq "amd64") {
                Join-Path $MountPath "virtio-win-gt-x64.msi"
            } else {
                Join-Path $MountPath "virtio-win-gt-x86.msi"
            }

            if (Test-Path $MsiPath) {
                Write-Status "Installing VirtIO Guest Tools via MSI..."
                $Process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$MsiPath`" /quiet /norestart" -Wait -PassThru

                if ($Process.ExitCode -eq 0) {
                    Write-Success "VirtIO Guest Tools installed successfully"
                }
            }
            else {
                Write-Warn "Guest tools installer not found on ISO"
            }
        }
    }
}
finally {
    # Always dismount ISO
    Write-Status "Dismounting ISO..."
    Dismount-DiskImage -ImagePath $IsoPath -ErrorAction SilentlyContinue | Out-Null
    Write-Success "ISO dismounted"

    # Cleanup downloaded ISO
    Write-Status "Cleaning up..."
    Remove-Item -Path $IsoPath -Force -ErrorAction SilentlyContinue
    Write-Success "Temporary files removed"
}

Write-Host ""
Write-Success "Installation complete!"
Write-Host ""
Write-Host "Installed components:" -ForegroundColor White
if (-not $SkipDrivers) {
    Write-Host "  - VirtIO drivers (storage, network, balloon, serial, etc.)" -ForegroundColor Gray
}
if (-not $SkipGuestTools) {
    Write-Host "  - QEMU Guest Agent and VirtIO tools" -ForegroundColor Gray
}
Write-Host ""
Write-Host "A reboot may be required for all drivers to take effect." -ForegroundColor Yellow
