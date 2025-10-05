#!/usr/bin/env bash
# setup_sdk_macos.sh - Download and setup Connect IQ SDK for macOS using CLI SDK Manager
# Uses the lindell/connect-iq-sdk-manager-cli tool (no GUI required!)

set -euo pipefail

# Configuration
SDK_DIR="$HOME/connectiq-sdk"
# SDK version: Use semver pattern (e.g., ^7.0.0) or exact version (e.g., 7.3.1)
# Note: "latest" is NOT supported - use ^7.0.0 or ^8.0.0 for latest in major version
SDK_VERSION="${CONNECTIQ_SDK_VERSION:-^7.0.0}"  # Default: latest 7.x

echo "============================================"
echo "Connect IQ SDK Setup for macOS (CLI)"
echo "============================================"
echo ""

# Detect architecture (for display only)
ARCH=$(uname -m)
echo "Detected architecture: $ARCH"
echo ""

# Step 1: Install CLI SDK Manager (always gets latest version)
echo "[1/4] Installing CLI SDK Manager (latest version)..."
echo "      Using official install script"
if ! curl -s https://raw.githubusercontent.com/lindell/connect-iq-sdk-manager-cli/master/install.sh | sh -s -- -b /tmp; then
    echo "ERROR: Failed to install CLI SDK Manager"
    exit 1
fi
echo "      CLI SDK Manager installed"
echo ""

# Step 2: Accept license agreement (required)
echo "[2/4] Accepting SDK license agreement..."
# Generate acceptance hash by viewing agreement first
AGREEMENT_HASH=$(/tmp/connect-iq-sdk-manager agreement view 2>&1 | grep -oE 'Agreement Hash: [a-f0-9]+' | cut -d' ' -f3 | head -1 || echo "")
if [ -z "${AGREEMENT_HASH}" ]; then
    echo "      Warning: Could not get agreement hash, using default accept"
    /tmp/connect-iq-sdk-manager agreement accept || true
else
    echo "      Agreement hash: ${AGREEMENT_HASH}"
    /tmp/connect-iq-sdk-manager agreement accept --agreement-hash="${AGREEMENT_HASH}"
fi
echo "      License accepted"
echo ""

# Step 2.5: Login to Garmin (required for SDK download)
echo "[2.5/4] Logging in to Garmin..."
if [ -n "${GARMIN_USERNAME:-}" ] && [ -n "${GARMIN_PASSWORD:-}" ]; then
    echo "      Using credentials from environment variables"
    /tmp/connect-iq-sdk-manager login --username="${GARMIN_USERNAME}" --password="${GARMIN_PASSWORD}"
else
    echo "      WARN: GARMIN_USERNAME and GARMIN_PASSWORD not set"
    echo "      Will attempt OAuth login (opens browser)"
    echo "      For automation, set these environment variables:"
    echo "        export GARMIN_USERNAME=your_email@example.com"
    echo "        export GARMIN_PASSWORD=your_password"
    echo ""
    /tmp/connect-iq-sdk-manager login
fi
echo "      Login successful"
echo ""

# Step 3: Download and set SDK version
echo "[3/6] Downloading Connect IQ SDK ${SDK_VERSION}..."

# First, list available SDKs to show what's available
echo "      Fetching available SDK versions..."
/tmp/connect-iq-sdk-manager sdk list 2>/dev/null | head -10 || true
echo ""

# Install the requested SDK version
if ! /tmp/connect-iq-sdk-manager sdk set "${SDK_VERSION}"; then
    echo "ERROR: SDK installation failed for version: ${SDK_VERSION}"
    echo "      Try setting CONNECTIQ_SDK_VERSION to a specific version (e.g., '7.3.1' or '^7.0.0')"
    exit 1
fi
echo "      SDK downloaded and activated"
echo ""

# Step 4: Download required devices
echo "[4/6] Downloading required devices..."
echo "      Target devices: fr265, fenix7, epix2, venu2"

# Download all devices at once using the correct command
/tmp/connect-iq-sdk-manager device download --device fr265 --device fenix7 --device epix2 --device venu2 || {
    echo "      Warning: Device download failed, trying one by one..."
    for device in fr265 fenix7 epix2 venu2; do
        echo "      Downloading ${device}..."
        /tmp/connect-iq-sdk-manager device download --device "${device}" || echo "      Warning: Could not download ${device}"
    done
}

echo "      Devices downloaded"
echo ""

# Step 5: Find SDK and create symlink
echo "[5/6] Creating SDK symlink..."
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

# Step 6: Verify devices are available
echo "[6/6] Verifying device installation..."

# Find where devices are stored (macOS specific paths)
DEVICES_DIR=""
if [ -d "$HOME/Library/Application Support/Garmin/ConnectIQ/Devices" ]; then
    DEVICES_DIR="$HOME/Library/Application Support/Garmin/ConnectIQ/Devices"
elif [ -d "$HOME/.Garmin/ConnectIQ/Devices" ]; then
    DEVICES_DIR="$HOME/.Garmin/ConnectIQ/Devices"
elif [ -d "${SDK_DIR}/devices" ]; then
    DEVICES_DIR="${SDK_DIR}/devices"
fi

if [ -n "${DEVICES_DIR}" ] && [ -d "${DEVICES_DIR}" ]; then
    echo "      Devices directory: ${DEVICES_DIR}"
    echo "      Available devices:"
    for device in fr265 fenix7 epix2 venu2; do
        if [ -d "${DEVICES_DIR}/${device}" ]; then
            echo "        ✓ ${device}"
        else
            echo "        ✗ ${device} (not found)"
        fi
    done
else
    echo "      Warning: Devices directory not found"
    echo "      Expected at: ~/Library/Application Support/Garmin/ConnectIQ/Devices"
fi
echo ""

echo ""
echo "============================================"
echo "✓ SDK Setup Complete!"
echo "============================================"
echo "SDK Location: ${SDK_DIR}"
echo "SDK Version:  ${MONKEYC_VERSION}"
if [ -n "${DEVICES_DIR}" ]; then
    echo "Devices:      ${DEVICES_DIR}"
fi
echo ""
echo "Environment variables (add to your shell profile):"
echo "  export SDK_HOME=\"${SDK_DIR}\""
echo "  export PATH=\"\${SDK_DIR}/bin:\$PATH\""
echo ""
echo "To use immediately in this session:"
echo "  source <(echo 'export SDK_HOME=\"${SDK_DIR}\"')"
echo "  source <(echo 'export PATH=\"${SDK_DIR}/bin:\$PATH\"')"
echo ""
