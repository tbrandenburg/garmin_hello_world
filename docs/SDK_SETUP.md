# Connect IQ SDK Setup Guide

Complete guide for setting up the Garmin Connect IQ SDK using the CLI Manager (no GUI required).

## Quick Start

### macOS
```bash
./scripts/setup_sdk_macos.sh
export SDK_HOME="$HOME/connectiq-sdk"
export PATH="$SDK_HOME/bin:$PATH"
make validate
```

### Linux
```bash
./scripts/setup_sdk.sh
export SDK_HOME="$HOME/connectiq-sdk"
export PATH="$SDK_HOME/bin:$PATH"
make validate
```

## What is the CLI SDK Manager?

The **Connect IQ SDK Manager CLI** ([lindell/connect-iq-sdk-manager-cli](https://github.com/lindell/connect-iq-sdk-manager-cli)) is a command-line tool that automates SDK installation without requiring GUI components. Perfect for:

- **CI/CD pipelines** (GitHub Actions, GitLab CI)
- **Headless servers** (no X11 or GUI libraries)
- **Automated environments** (Docker, VMs)
- **Local development** (simpler than GUI manager)

### Why CLI Instead of GUI?

| Feature | CLI Manager | GUI SDK Manager |
|---------|-------------|-----------------|
| **Headless Support** | ✅ Yes | ❌ No |
| **CI/CD Ready** | ✅ Yes | ❌ No |
| **Scriptable** | ✅ Fully | ⚠️ Limited |
| **Speed** | ⚡ ~30s | 🐌 2-3 minutes |
| **Automation** | ✅ Full | ❌ Manual |

## Installation

### Automated Setup (Recommended)

**macOS:**
```bash
./scripts/setup_sdk_macos.sh
```

**Linux:**
```bash
./scripts/setup_sdk.sh
```

The script will:
1. Download CLI Manager (automatically gets latest version)
2. Accept license agreement
3. Login to Garmin (requires credentials)
4. Install SDK (^7.0.0 by default = latest 7.x)
5. Create symlink at `~/connectiq-sdk`
6. Validate installation

**Note:** The CLI Manager is installed using the [official install script](https://github.com/lindell/connect-iq-sdk-manager-cli#automatic-binary-install) which always downloads the latest version.

### Manual Setup

If you prefer to install manually:

**1. Download CLI Manager:**

**Automatic (Recommended - Always Gets Latest):**
```bash
# Automatically downloads and installs latest version
curl -s https://raw.githubusercontent.com/lindell/connect-iq-sdk-manager-cli/master/install.sh | sh
```

**Manual (If Preferred):**
```bash
# macOS
VERSION="0.7.1"  # Check https://github.com/lindell/connect-iq-sdk-manager-cli/releases for latest
ARCH=$(uname -m)
PLATFORM=$([ "$ARCH" = "arm64" ] && echo "Darwin_ARM64" || echo "Darwin_x86_64")
curl -L -o /tmp/cli-sdk-manager.tar.gz \
  "https://github.com/lindell/connect-iq-sdk-manager-cli/releases/download/v${VERSION}/connect-iq-sdk-manager-cli_${VERSION}_${PLATFORM}.tar.gz"
tar -xzf /tmp/cli-sdk-manager.tar.gz -C /tmp
chmod +x /tmp/connect-iq-sdk-manager
sudo mv /tmp/connect-iq-sdk-manager /usr/local/bin/

# Linux
VERSION="0.7.1"  # Check https://github.com/lindell/connect-iq-sdk-manager-cli/releases for latest
curl -L -o /tmp/cli-sdk-manager.tar.gz \
  "https://github.com/lindell/connect-iq-sdk-manager-cli/releases/download/v${VERSION}/connect-iq-sdk-manager-cli_${VERSION}_Linux_x86_64.tar.gz"
tar -xzf /tmp/cli-sdk-manager.tar.gz -C /tmp
chmod +x /tmp/connect-iq-sdk-manager
sudo mv /tmp/connect-iq-sdk-manager /usr/local/bin/
```

**2. Accept License:**
```bash
connect-iq-sdk-manager agreement view
connect-iq-sdk-manager agreement accept
```

**3. Login to Garmin:**
```bash
# Interactive OAuth (opens browser)
connect-iq-sdk-manager login

# Or use credentials (for automation)
export GARMIN_USERNAME="your_email@example.com"
export GARMIN_PASSWORD="your_password"
connect-iq-sdk-manager login
```

**4. Install SDK:**
```bash
# Latest 7.x SDK (recommended)
connect-iq-sdk-manager sdk set "^7.0.0"

# Latest 8.x SDK
connect-iq-sdk-manager sdk set "^8.0.0"

# Or exact version
connect-iq-sdk-manager sdk set "7.3.1"

# Note: "latest" is NOT a valid version pattern
```

**5. Configure Environment:**
```bash
SDK_PATH=$(connect-iq-sdk-manager sdk current-path)
ln -s "$SDK_PATH" ~/connectiq-sdk
export SDK_HOME="$HOME/connectiq-sdk"
export PATH="$SDK_HOME/bin:$PATH"
```

## SDK Version Management

### Default: Latest 7.x

The setup scripts default to installing the **latest 7.x** SDK using semver pattern `^7.0.0`:

```bash
./scripts/setup_sdk_macos.sh  # Installs latest 7.x
```

**Important:** The string "latest" is NOT supported by the CLI tool. Use semver patterns instead:
- `^7.0.0` - Latest 7.x release
- `^8.0.0` - Latest 8.x release  
- `7.3.1` - Exact version

**Pros:**
- ✅ Gets updates within major version
- ✅ Avoids breaking changes from major version bumps
- ✅ Predictable for CI/CD

**Cons:**
- ⚠️ Minor version updates may still have changes
- ⚠️ Requires manual update for new major versions

### Pin Specific Version

Override the default by setting `CONNECTIQ_SDK_VERSION`:

```bash
# Pin to latest 7.x
export CONNECTIQ_SDK_VERSION="^7.0.0"
./scripts/setup_sdk_macos.sh

# Pin to exact version
export CONNECTIQ_SDK_VERSION="7.3.1"
./scripts/setup_sdk_macos.sh
```

### Version Recommendations

| Use Case | Recommended Version | Why |
|----------|---------------------|-----|
| **Local Dev** | `^7.0.0` or `^8.0.0` | Latest in major version |
| **CI/CD** | `^7.0.0` | Stability + updates |
| **Releases** | `7.3.1` (exact) | Reproducibility |

### Check SDK Version

```bash
# Current version
monkeyc --version

# Available versions
connect-iq-sdk-manager-cli sdk list
```

## Essential Commands

### SDK Management
```bash
# Login first (required)
connect-iq-sdk-manager login
# Or with credentials:
export GARMIN_USERNAME="your_email@example.com"
export GARMIN_PASSWORD="your_password"
connect-iq-sdk-manager login

# List available versions
connect-iq-sdk-manager sdk list

# Install latest 7.x (semver pattern)
connect-iq-sdk-manager sdk set "^7.0.0"

# Install latest 8.x
connect-iq-sdk-manager sdk set "^8.0.0"

# Install specific version
connect-iq-sdk-manager sdk set "7.3.1"

# Get SDK path
connect-iq-sdk-manager sdk current-path

# Get binary path
connect-iq-sdk-manager sdk current-path --bin
```

### Device Management
```bash
# List devices
connect-iq-sdk-manager device list

# Download device profile
connect-iq-sdk-manager device download fenix7

# Download with fonts
connect-iq-sdk-manager device download fenix7 --include-fonts
```

### Build Commands
```bash
# Validate environment
make validate

# Build for default device
make build

# Build for specific device
make build DEVICE=fenix7

# Build all devices (parallel)
make buildall -j4

# Build and run
make run DEVICE=epix2
```

## CI/CD Integration

### GitHub Actions

The project's workflow (`.github/workflows/build-and-test.yml`) uses:

```yaml
env:
  # Pin to latest 7.x for CI stability
  CONNECTIQ_SDK_VERSION: "^7.0.0"

jobs:
  build-and-test:
    steps:
      - name: Setup Garmin Credentials
        run: |
          echo "GARMIN_USERNAME=${{ secrets.GARMIN_USERNAME }}" >> $GITHUB_ENV
          echo "GARMIN_PASSWORD=${{ secrets.GARMIN_PASSWORD }}" >> $GITHUB_ENV
      
      - name: Cache SDK
        uses: actions/cache@v4
        with:
          path: |
            ~/connectiq-sdk
            ~/.Garmin/ConnectIQ/Sdks
          key: connectiq-sdk-${{ runner.os }}-${{ env.CONNECTIQ_SDK_VERSION }}-v3
      
      - name: Setup SDK
        run: ./scripts/setup_sdk.sh
```

**Benefits:**
- ✅ No GUI libraries required
- ✅ Fast (~30 seconds)
- ✅ Cache-friendly
- ✅ Version-controlled

**Required Secrets:**
- `GARMIN_USERNAME` - Your Garmin Connect email
- `GARMIN_PASSWORD` - Your Garmin Connect password
- `MONKEYC_KEY_B64` - Base64-encoded developer key

### GitLab CI

```yaml
setup-sdk:
  stage: setup
  script:
    - ./scripts/setup_sdk.sh
  variables:
    CONNECTIQ_SDK_VERSION: "^7.0.0"
  cache:
    paths:
      - ~/connectiq-sdk
      - ~/.Garmin/ConnectIQ/Sdks
```

### Docker

```dockerfile
FROM ubuntu:latest

RUN apt-get update && apt-get install -y curl

# Install CLI Manager
RUN VERSION=0.7.1 && \
    curl -L -o /tmp/cli-sdk-manager.tar.gz \
      "https://github.com/lindell/connect-iq-sdk-manager-cli/releases/download/v${VERSION}/connect-iq-sdk-manager-cli_${VERSION}_Linux_x86_64.tar.gz" && \
    tar -xzf /tmp/cli-sdk-manager.tar.gz -C /tmp && \
    chmod +x /tmp/connect-iq-sdk-manager && \
    mv /tmp/connect-iq-sdk-manager /usr/local/bin/

# Login and install SDK
ARG GARMIN_USERNAME
ARG GARMIN_PASSWORD
RUN connect-iq-sdk-manager agreement accept && \
    connect-iq-sdk-manager login --username="${GARMIN_USERNAME}" --password="${GARMIN_PASSWORD}" && \
    connect-iq-sdk-manager sdk set "^7.0.0"

ENV SDK_HOME=/root/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-*
ENV PATH="${SDK_HOME}/bin:${PATH}"
```

## Troubleshooting

### SDK Not Found
```bash
# Check path
connect-iq-sdk-manager sdk current-path

# Reinstall (ensure you're logged in first)
connect-iq-sdk-manager login
connect-iq-sdk-manager sdk set "^7.0.0"

# Recreate symlink
ln -sf $(connect-iq-sdk-manager sdk current-path) ~/connectiq-sdk
```

### License Not Accepted
```bash
# View and accept
connect-iq-sdk-manager agreement view
connect-iq-sdk-manager agreement accept
```

### Permission Denied
```bash
# Make executable
chmod +x /tmp/connect-iq-sdk-manager

# Or if globally installed
sudo chmod +x /usr/local/bin/connect-iq-sdk-manager
```

### Build Fails After Update
```bash
# Roll back to previous version
export CONNECTIQ_SDK_VERSION="7.3.1"
./scripts/setup_sdk_macos.sh

# Rebuild
make clean
make build
```

### Device Not Found in Simulator
```bash
# Download device profiles
connect-iq-sdk-manager device download fenix7
connect-iq-sdk-manager device download venu2
connect-iq-sdk-manager device download epix2
```

## Environment Variables

```bash
# Required
export SDK_HOME="$HOME/connectiq-sdk"
export PATH="$SDK_HOME/bin:$PATH"

# Required: Garmin credentials (for SDK download)
export GARMIN_USERNAME="your_email@example.com"
export GARMIN_PASSWORD="your_password"

# Optional: Pin SDK version for setup scripts
export CONNECTIQ_SDK_VERSION="^7.0.0"  # Or "^8.0.0", "7.3.1", etc.
# Note: "latest" is NOT supported

# Optional: Signing key
export MONKEYC_KEY="$PWD/.keys/developer_key.der"

# Optional: CLI Manager logging
export LOG_LEVEL=debug
export LOG_FORMAT=json
```

## File Locations

```
~/connectiq-sdk/                  # SDK symlink (created by setup)
~/.Garmin/ConnectIQ/Sdks/         # Actual SDK installation
~/.Garmin/ConnectIQ/devices/      # Device profiles
$PROJECT/.keys/                   # Developer signing keys
$PROJECT/bin/                     # Build artifacts (.prg)
$PROJECT/dist/                    # Store packages (.iq)
```

## Development Workflow

### Fresh Setup
```bash
# 1. Clone repo
git clone <repo-url>
cd garmin_hello_world

# 2. Setup SDK
./scripts/setup_sdk_macos.sh

# 3. Configure environment
export SDK_HOME="$HOME/connectiq-sdk"
export PATH="$SDK_HOME/bin:$PATH"

# 4. Generate dev key (if needed)
./scripts/generate_ci_key.sh

# 5. Validate
make validate

# 6. Build
make build
```

### Daily Development
```bash
# Build and run
make run DEVICE=fenix7

# Or build only
make build DEVICE=fenix7
```

### Release Build
```bash
# Pin exact version for reproducibility
export CONNECTIQ_SDK_VERSION="7.3.1"

# Build optimized releases
make release -j4

# Create store package
make package

# Check artifacts
ls -lh dist/*.iq
```

## What Changed (Migration Notes)

### Previous Approach
- Required GUI SDK Manager
- Manual installation
- Not CI-friendly
- Used `^7.0.0` pinned version

### Current Approach (CLI Manager)
- ✅ No GUI required
- ✅ Fully automated
- ✅ CI/CD ready
- ✅ Defaults to `latest` SDK
- ✅ Override with `CONNECTIQ_SDK_VERSION`

### For Existing Users

**If you have GUI SDK Manager:**
- Both can coexist
- Makefile auto-detects your SDK
- Or switch to CLI with setup script

**To keep using `^7.0.0`:**
```bash
# Add to shell profile
echo 'export CONNECTIQ_SDK_VERSION="^7.0.0"' >> ~/.zshrc
```

## Further Reading

- **CLI Tool GitHub**: [lindell/connect-iq-sdk-manager-cli](https://github.com/lindell/connect-iq-sdk-manager-cli)
- **Connect IQ Docs**: [developer.garmin.com/connect-iq](https://developer.garmin.com/connect-iq)
- **Build System**: See [WARP.md](../WARP.md)
- **CI Workflow**: See [.github/workflows/build-and-test.yml](../.github/workflows/build-and-test.yml)

---

**Last Updated**: January 2025  
**CLI Version**: 0.7.1  
**Default SDK**: `latest`  
**Tested**: macOS (ARM64/Intel), Linux (AMD64)
