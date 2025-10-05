#!/usr/bin/env bash
# setup_sdk.sh - Download and setup Connect IQ SDK for CI using SDK Manager
# This is the official and recommended way to install the SDK

set -euo pipefail

# Configuration
SDK_MANAGER_URL="https://developer.garmin.com/downloads/connect-iq/sdk-manager/connectiq-sdk-manager-linux.zip"
SDK_DIR="$HOME/connectiq-sdk"
TMP_DIR="/tmp/ciq-setup-$$"

echo "============================================"
echo "Connect IQ SDK Setup (using SDK Manager)"
echo "============================================"
echo ""

# Create temp directory
mkdir -p "${TMP_DIR}"
cd "${TMP_DIR}"

# Step 1: Download SDK Manager
echo "[1/4] Downloading SDK Manager..."
if ! curl -L -f -o sdk-manager-linux.zip "${SDK_MANAGER_URL}"; then
    echo "ERROR: Failed to download SDK Manager"
    echo "URL: ${SDK_MANAGER_URL}"
    exit 1
fi
echo "      Downloaded: $(du -h sdk-manager-linux.zip | cut -f1)"
echo ""

# Step 2: Extract SDK Manager
echo "[2/4] Extracting SDK Manager..."
if ! unzip -q sdk-manager-linux.zip; then
    echo "ERROR: Failed to extract SDK Manager"
    exit 1
fi
echo "      Extracted successfully"
echo ""

# Step 3: Run SDK Manager to install SDK
echo "[3/4] Installing Connect IQ SDK (this may take a few minutes)..."
cd sdkmanager || {
    echo "ERROR: sdkmanager directory not found"
    ls -la
    exit 1
}

# Make manager executable
chmod +x sdkmanager 2>/dev/null || true

# Install SDK - it will be placed in a predictable location
if ! ./sdkmanager --accept-license --install linux; then
    echo "ERROR: SDK installation failed"
    exit 1
fi
echo "      SDK installed successfully"
echo ""

# Step 4: Find and link SDK
echo "[4/4] Locating and linking SDK..."

# SDK Manager installs to ~/.Garmin/ConnectIQ/Sdks/
SDK_INSTALLED_DIR="$HOME/.Garmin/ConnectIQ/Sdks"

if [ ! -d "${SDK_INSTALLED_DIR}" ]; then
    echo "ERROR: SDK directory not found at ${SDK_INSTALLED_DIR}"
    echo "Checking alternate locations..."
    find "$HOME" -type d -name "connectiq-sdk-*" 2>/dev/null || true
    exit 1
fi

# Find the latest SDK version installed
LATEST_SDK=$(find "${SDK_INSTALLED_DIR}" -maxdepth 1 -type d -name "connectiq-sdk-*" | sort -V | tail -n1)

if [ -z "${LATEST_SDK}" ]; then
    echo "ERROR: No SDK found in ${SDK_INSTALLED_DIR}"
    ls -la "${SDK_INSTALLED_DIR}"
    exit 1
fi

echo "      Found SDK: $(basename "${LATEST_SDK}")"

# Create symlink to standard location
if [ -L "${SDK_DIR}" ]; then
    rm "${SDK_DIR}"
fi

ln -s "${LATEST_SDK}" "${SDK_DIR}"
echo "      Linked to: ${SDK_DIR}"
echo ""

# Step 5: Validate installation
echo "[5/5] Validating installation..."

if [ ! -f "${SDK_DIR}/bin/monkeyc" ]; then
    echo "ERROR: monkeyc not found at ${SDK_DIR}/bin/monkeyc"
    echo "SDK contents:"
    ls -la "${SDK_DIR}/bin/" 2>/dev/null || echo "bin directory not found"
    exit 1
fi

echo "      monkeyc found"

# Get version
MONKEYC_VERSION=$("${SDK_DIR}/bin/monkeyc" --version 2>&1 | head -n1 || echo "unknown")
echo "      Version: ${MONKEYC_VERSION}"
echo ""

# Cleanup
echo "Cleaning up temporary files..."
rm -rf "${TMP_DIR}"

echo ""
echo "============================================"
echo "✓ SDK Setup Complete!"
echo "============================================"
echo "SDK Location: ${SDK_DIR}"
echo "Version:      ${MONKEYC_VERSION}"
echo ""
echo "Environment variables:"
echo "  export SDK_HOME=\"${SDK_DIR}\""
echo "  export PATH=\"\${SDK_DIR}/bin:\$PATH\""
echo ""
