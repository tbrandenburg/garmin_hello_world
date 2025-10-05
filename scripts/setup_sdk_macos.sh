#!/usr/bin/env bash
# setup_sdk_macos.sh - Download and setup Connect IQ SDK for macOS using CLI SDK Manager
# Uses the lindell/connect-iq-sdk-manager-cli tool (no GUI required!)

set -euo pipefail

# Configuration
CLI_SDK_MANAGER_VERSION="v0.7.1"
SDK_DIR="$HOME/connectiq-sdk"
# Use latest available SDK by default, or override with environment variable
SDK_VERSION="${CONNECTIQ_SDK_VERSION:-latest}"  # Default: latest, or set CONNECTIQ_SDK_VERSION to pin

echo "============================================"
echo "Connect IQ SDK Setup for macOS (CLI)"
echo "============================================"
echo ""

# Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    PLATFORM="Darwin_ARM64"
elif [ "$ARCH" = "x86_64" ]; then
    PLATFORM="Darwin_x86_64"
else
    echo "ERROR: Unsupported architecture: $ARCH"
    exit 1
fi

echo "Detected architecture: $ARCH (using $PLATFORM binary)"
echo ""

# Step 1: Install CLI SDK Manager
echo "[1/4] Installing CLI SDK Manager (no GUI!)..."
# Remove 'v' prefix from version for filename, use correct format from GitHub releases
VERSION_NO_V="${CLI_SDK_MANAGER_VERSION#v}"
CLI_URL="https://github.com/lindell/connect-iq-sdk-manager-cli/releases/download/${CLI_SDK_MANAGER_VERSION}/connect-iq-sdk-manager-cli_${VERSION_NO_V}_${PLATFORM}.tar.gz"

echo "      Downloading from: ${CLI_URL}"
if ! curl -L -f -o /tmp/cli-sdk-manager.tar.gz "${CLI_URL}"; then
    echo "ERROR: Failed to download CLI SDK Manager"
    echo "URL: ${CLI_URL}"
    exit 1
fi

tar -xzf /tmp/cli-sdk-manager.tar.gz -C /tmp
# The binary name inside is 'connect-iq-sdk-manager-cli'
chmod +x /tmp/connect-iq-sdk-manager-cli
echo "      CLI SDK Manager installed"
echo ""

# Step 2: Accept license agreement (required)
echo "[2/4] Accepting SDK license agreement..."
# Generate acceptance hash by viewing agreement first
AGREEMENT_HASH=$(/tmp/connect-iq-sdk-manager-cli agreement view 2>&1 | grep -oE 'Agreement Hash: [a-f0-9]+' | cut -d' ' -f3 | head -1 || echo "")
if [ -z "${AGREEMENT_HASH}" ]; then
    echo "      Warning: Could not get agreement hash, using default accept"
    /tmp/connect-iq-sdk-manager-cli agreement accept || true
else
    echo "      Agreement hash: ${AGREEMENT_HASH}"
    /tmp/connect-iq-sdk-manager-cli agreement accept --agreement-hash="${AGREEMENT_HASH}"
fi
echo "      License accepted"
echo ""

# Step 3: Download and set SDK version
echo "[3/4] Downloading Connect IQ SDK ${SDK_VERSION}..."

# First, list available SDKs to show what's available
echo "      Fetching available SDK versions..."
/tmp/connect-iq-sdk-manager-cli sdk list 2>/dev/null | head -10 || true
echo ""

# Install the requested SDK version
if ! /tmp/connect-iq-sdk-manager-cli sdk set "${SDK_VERSION}"; then
    echo "ERROR: SDK installation failed for version: ${SDK_VERSION}"
    echo "      Try setting CONNECTIQ_SDK_VERSION to a specific version (e.g., '7.3.1' or '^7.0.0')"
    exit 1
fi
echo "      SDK downloaded and activated"
echo ""

# Step 4: Find SDK and create symlink
echo "[4/4] Creating SDK symlink..."
SDK_PATH=$(/tmp/connect-iq-sdk-manager-cli sdk current-path)

if [ -z "${SDK_PATH}" ] || [ ! -d "${SDK_PATH}" ]; then
    echo "ERROR: SDK path not found"
    exit 1
fi

echo "      Found SDK at: ${SDK_PATH}"

# Create symlink
if [ -L "${SDK_DIR}" ]; then
    rm "${SDK_DIR}"
fi
ln -s "${SDK_PATH}" "${SDK_DIR}"
echo "      Symlink created: ${SDK_DIR} -> ${SDK_PATH}"
echo ""

# Validate installation
if [ ! -f "${SDK_DIR}/bin/monkeyc" ]; then
    echo "ERROR: monkeyc not found at ${SDK_DIR}/bin/monkeyc"
    exit 1
fi

MONKEYC_VERSION=$("${SDK_DIR}/bin/monkeyc" --version 2>&1 | head -n1 || echo "unknown")

echo ""
echo "============================================"
echo "✓ SDK Setup Complete!"
echo "============================================"
echo "SDK Location: ${SDK_DIR}"
echo "Version:      ${MONKEYC_VERSION}"
echo "CLI Tool:     ${CLI_SDK_MANAGER_VERSION}"
echo ""
echo "Environment variables (add to your shell profile):"
echo "  export SDK_HOME=\"${SDK_DIR}\""
echo "  export PATH=\"\${SDK_DIR}/bin:\$PATH\""
echo ""
echo "To use immediately in this session:"
echo "  source <(echo 'export SDK_HOME=\"${SDK_DIR}\"')"
echo "  source <(echo 'export PATH=\"${SDK_DIR}/bin:\$PATH\"')"
echo ""
