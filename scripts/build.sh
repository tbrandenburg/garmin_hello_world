#!/bin/bash

# Build script for Garmin Hello World app
# DEPRECATED: Please use Makefile instead
# This script is maintained for backward compatibility

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Deprecation notice
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}DEPRECATION NOTICE${NC}"
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}This build script is deprecated.${NC}"
echo -e "${YELLOW}Please use the Makefile instead:${NC}"
echo -e ""
echo -e "  ${GREEN}make build${NC}              # Build for default device"
echo -e "  ${GREEN}make build DEVICE=fenix7${NC} # Build for specific device"
echo -e "  ${GREEN}make buildall -j${NC}        # Build for all devices"
echo -e "  ${GREEN}make help${NC}               # Show all targets"
echo -e ""
echo -e "${YELLOW}Forwarding to Makefile...${NC}"
echo -e "${YELLOW}========================================${NC}"
echo -e ""

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

# Forward to Makefile (accept DEVICE env var or first argument)
DEVICE_ARG="${DEVICE:-${1:-fr265}}"

echo -e "${GREEN}Forwarding to: make build DEVICE=$DEVICE_ARG${NC}\n"

# Execute make and preserve exit code
exec make build DEVICE="$DEVICE_ARG"
