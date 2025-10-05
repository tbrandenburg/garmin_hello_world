#!/usr/bin/env bash
# setup_sdk.sh - Download and setup Connect IQ SDK for CI

set -euo pipefail

SDK_URL="${CONNECTIQ_SDK_URL:-https://developer.garmin.com/downloads/connect-iq/sdks/connectiq-sdk-lin-4.2.4-2023-12-06-5b5e4a8ca.zip}"
SDK_DIR="$HOME/connectiq-sdk"

echo "Downloading Connect IQ SDK..."
wget -q "${SDK_URL}" -O /tmp/ciq-sdk.zip

echo "Extracting SDK..."
unzip -q /tmp/ciq-sdk.zip -d /tmp

# Move SDK to target directory
SDK_EXTRACTED=$(find /tmp -maxdepth 1 -type d -name 'connectiq-sdk-*' | head -n1)
if [ -z "${SDK_EXTRACTED}" ]; then
    echo "ERROR: SDK extraction failed - no connectiq-sdk-* directory found"
    exit 1
fi

mv "${SDK_EXTRACTED}" "${SDK_DIR}"

echo "SDK installed to: ${SDK_DIR}"
"${SDK_DIR}/bin/monkeyc" --version || echo "WARNING: monkeyc version check failed"

echo ""
echo "SDK setup complete!"
echo "Add to PATH: export PATH=\"\${SDK_DIR}/bin:\$PATH\""
echo "Set SDK_HOME: export SDK_HOME=\"${SDK_DIR}\""
