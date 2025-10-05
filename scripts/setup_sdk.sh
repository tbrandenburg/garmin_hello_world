#!/usr/bin/env bash
# setup_sdk.sh - Download and setup Connect IQ SDK for CI using CLI SDK Manager
# Uses the lindell/connect-iq-sdk-manager-cli tool (no GUI required!)

set -euo pipefail

# Configuration
CLI_SDK_MANAGER_VERSION="v0.7.1"
SDK_DIR="$HOME/connectiq-sdk"
SDK_VERSION="^7.0.0"  # Latest 7.x SDK

echo "============================================"
echo "Connect IQ SDK Setup (CLI, no GUI!)"
echo "============================================"
echo ""

# Step 1: Install CLI SDK Manager
echo "[1/4] Installing CLI SDK Manager (no GUI!)..."
CLI_URL="https://github.com/lindell/connect-iq-sdk-manager-cli/releases/download/${CLI_SDK_MANAGER_VERSION}/connect-iq-sdk-manager_${CLI_SDK_MANAGER_VERSION}_linux_amd64.tar.gz"

if ! curl -L -f -o /tmp/cli-sdk-manager.tar.gz "${CLI_URL}"; then
    echo "ERROR: Failed to download CLI SDK Manager"
    echo "URL: ${CLI_URL}"
    exit 1
fi

tar -xzf /tmp/cli-sdk-manager.tar.gz -C /tmp
chmod +x /tmp/connect-iq-sdk-manager
echo "      CLI SDK Manager installed"
echo ""

# Step 2: Accept license agreement (required)
echo "[2/4] Accepting SDK license agreement..."
# Generate acceptance hash by viewing agreement first
AGREEMENT_HASH=$(/tmp/connect-iq-sdk-manager agreement view 2>&1 | grep -oP 'Agreement Hash: \K[a-f0-9]+' | head -1 || echo "")
if [ -z "${AGREEMENT_HASH}" ]; then
    echo "      Warning: Could not get agreement hash, using default accept"
    /tmp/connect-iq-sdk-manager agreement accept || true
else
    echo "      Agreement hash: ${AGREEMENT_HASH}"
    /tmp/connect-iq-sdk-manager agreement accept --agreement-hash="${AGREEMENT_HASH}"
fi
echo "      License accepted"
echo ""

# Step 3: Download and set SDK version
echo "[3/4] Downloading Connect IQ SDK ${SDK_VERSION}..."
if ! /tmp/connect-iq-sdk-manager sdk set "${SDK_VERSION}"; then
    echo "ERROR: SDK installation failed"
    exit 1
fi
echo "      SDK downloaded and activated"
echo ""

# Step 4: Find SDK and create symlink
echo "[4/4] Creating SDK symlink..."
SDK_PATH=$(/tmp/connect-iq-sdk-manager sdk current-path)

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
echo "Environment variables:"
echo "  export SDK_HOME=\"${SDK_DIR}\""
echo "  export PATH=\"\${SDK_DIR}/bin:\$PATH\""
echo ""
