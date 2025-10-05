#!/bin/bash

# Build script for Garmin Hello World app
# This script builds the app for one or more target devices

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Garmin Hello World Build Script ===${NC}\n"

# Check if monkeyc is available
if ! command -v monkeyc &> /dev/null; then
    echo -e "${RED}Error: monkeyc command not found!${NC}"
    echo "Please install Connect IQ SDK and add it to your PATH."
    echo "See BUILD.md for setup instructions."
    exit 1
fi

# Check if developer key exists
if [ ! -f ".keys/developer_key.der" ]; then
    echo -e "${RED}Error: Developer key not found!${NC}"
    echo "Please run: openssl genrsa -out .keys/developer_key.pem 4096"
    echo "Then: openssl pkcs8 -topk8 -inform PEM -outform DER -in .keys/developer_key.pem -out .keys/developer_key.der -nocrypt"
    exit 1
fi

# Create bin directory
mkdir -p bin

# Default device
DEVICE=${1:-fr265}
echo -e "Building for device: ${YELLOW}${DEVICE}${NC}\n"

# Build the app
echo "Compiling..."
monkeyc \
    -f monkey.jungle \
    -d "${DEVICE}" \
    -o "bin/garmin_hello_world_${DEVICE}.prg" \
    -y .keys/developer_key.der

if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}✓ Build successful!${NC}"
    echo -e "Output: bin/garmin_hello_world_${DEVICE}.prg"
    echo -e "\nTo run in simulator:"
    echo -e "  ${YELLOW}monkeydo bin/garmin_hello_world_${DEVICE}.prg ${DEVICE}${NC}"
else
    echo -e "\n${RED}✗ Build failed!${NC}"
    exit 1
fi
