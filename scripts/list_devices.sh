#!/bin/bash
# list_devices.sh - Extract supported device IDs from manifest.xml
# Usage: list_devices.sh [manifest_file]
# Outputs one device ID per line

set -euo pipefail

# Default to manifest.xml if no argument provided
MANIFEST="${1:-manifest.xml}"

# Check if manifest file exists
if [ ! -f "$MANIFEST" ]; then
    echo "Error: Manifest file '$MANIFEST' not found" >&2
    echo "Please ensure manifest.xml exists in the project root" >&2
    exit 1
fi

# Extract device IDs from <iq:product id="..."/> lines
# Use grep to find product lines, sed to extract id values, sort unique
DEVICES=$(grep -i 'product.*id=' "$MANIFEST" | \
          sed -n 's/.*id="\([^"]*\)".*/\1/p' | \
          sort -u)

# Check if we found any devices
if [ -z "$DEVICES" ]; then
    echo "Error: No devices found in $MANIFEST" >&2
    echo "Please check the <iq:products> section in your manifest" >&2
    exit 1
fi

# Output device list (one per line)
echo "$DEVICES"
