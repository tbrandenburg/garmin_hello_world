#!/usr/bin/env bash
# setup_sdk.sh - Download and setup Connect IQ SDK for CI

set -euo pipefail

# Use SDK 7.x for better compatibility and latest features
# Update this URL as newer SDKs become available
SDK_URL="${CONNECTIQ_SDK_URL:-https://developer.garmin.com/downloads/connect-iq/sdks/connectiq-sdk-lin-7.3.1-2024-11-18-2b2afeb8e.zip}"
SDK_DIR="$HOME/connectiq-sdk"

echo "Downloading Connect IQ SDK from:"
echo "  ${SDK_URL}"
echo ""

if ! wget --spider -q "${SDK_URL}"; then
    echo "ERROR: SDK URL is not accessible"
    echo "Please update SDK_URL in scripts/setup_sdk.sh"
    echo "Find latest SDK at: https://developer.garmin.com/connect-iq/sdk/"
    exit 1
fi

echo "Downloading SDK..."
if ! wget -q "${SDK_URL}" -O /tmp/ciq-sdk.zip; then
    echo "ERROR: Download failed"
    exit 1
fi

echo "Download complete ($(du -h /tmp/ciq-sdk.zip | cut -f1))"

echo "Extracting SDK..."
if ! unzip -q /tmp/ciq-sdk.zip -d /tmp; then
    echo "ERROR: SDK extraction failed"
    exit 1
fi

# Move SDK to target directory
SDK_EXTRACTED=$(find /tmp -maxdepth 1 -type d -name 'connectiq-sdk-*' | head -n1)
if [ -z "${SDK_EXTRACTED}" ]; then
    echo "ERROR: SDK extraction failed - no connectiq-sdk-* directory found"
    echo "Contents of /tmp:"
    ls -la /tmp/connectiq* 2>/dev/null || echo "No connectiq files found"
    exit 1
fi

echo "Moving ${SDK_EXTRACTED} to ${SDK_DIR}"
mv "${SDK_EXTRACTED}" "${SDK_DIR}"

# Validate installation
if [ ! -f "${SDK_DIR}/bin/monkeyc" ]; then
    echo "ERROR: monkeyc not found after installation"
    echo "SDK directory contents:"
    ls -la "${SDK_DIR}/bin/" 2>/dev/null || echo "bin directory not found"
    exit 1
fi

echo "SDK installed to: ${SDK_DIR}"
echo "Validating monkeyc..."
"${SDK_DIR}/bin/monkeyc" --version

echo ""
echo "SDK setup complete!"
echo "Add to PATH: export PATH=\"\${SDK_DIR}/bin:\$PATH\""
echo "Set SDK_HOME: export SDK_HOME=\"${SDK_DIR}\""
