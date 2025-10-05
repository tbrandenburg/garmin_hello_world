#!/bin/bash
# validate_env.sh - Validate Connect IQ development environment
# Checks SDK installation, tools, keys, and project files
# Exit 0 on success, non-zero on failure

set -euo pipefail

# Color codes
C_RESET='\033[0m'
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_RED='\033[31m'
C_BLUE='\033[34m'

# Symbols
OK="✓"
ERR="✗"
WARN="!"

# Status tracking
ERRORS=0

# Helper functions
print_check() {
    printf "${C_BLUE}[CHECK]${C_RESET} %s... " "$1"
}

print_ok() {
    printf "${C_GREEN}${OK} %s${C_RESET}\n" "$1"
}

print_error() {
    printf "${C_RED}${ERR} %s${C_RESET}\n" "$1"
    ERRORS=$((ERRORS + 1))
}

print_warn() {
    printf "${C_YELLOW}${WARN} %s${C_RESET}\n" "$1"
}

print_info() {
    printf "${C_BLUE}[INFO]${C_RESET} %s\n" "$1"
}

# Start validation
echo ""
printf "${C_BLUE}=== Connect IQ Environment Validation ===${C_RESET}\n\n"

# Check SDK_HOME
print_check "SDK_HOME is set"
if [ -z "${SDK_HOME:-}" ]; then
    print_error "SDK_HOME is not set"
    echo "  Set SDK_HOME in properties.mk or as environment variable"
    echo "  Example: SDK_HOME=~/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-8.3.0-*"
else
    print_ok "Set to: $SDK_HOME"
fi

# Check SDK_HOME directory exists
if [ -n "${SDK_HOME:-}" ]; then
    print_check "SDK_HOME directory exists"
    if [ ! -d "$SDK_HOME" ]; then
        print_error "Directory not found: $SDK_HOME"
    else
        print_ok "Found"
    fi
fi

# Check monkeyc compiler
print_check "monkeyc compiler"
MONKEYC="${MONKEYC:-${SDK_HOME:-}/bin/monkeyc}"
if [ ! -x "$MONKEYC" ]; then
    print_error "Not found or not executable: $MONKEYC"
    echo "  Install Connect IQ SDK via SDK Manager"
else
    print_ok "Found at: $MONKEYC"
fi

# Check monkeydo simulator runner
print_check "monkeydo simulator"
MONKEYDO="${MONKEYDO:-${SDK_HOME:-}/bin/monkeydo}"
if [ ! -x "$MONKEYDO" ]; then
    print_error "Not found or not executable: $MONKEYDO"
    echo "  Install Connect IQ Simulator via SDK Manager"
else
    print_ok "Found at: $MONKEYDO"
fi

# Check manifest.xml
MANIFEST_FILE="${MANIFEST_FILE:-manifest.xml}"
print_check "Project manifest ($MANIFEST_FILE)"
if [ ! -f "$MANIFEST_FILE" ]; then
    print_error "File not found: $MANIFEST_FILE"
else
    print_ok "Found"
fi

# Check monkey.jungle
JUNGLE_FILE="${JUNGLE_FILE:-monkey.jungle}"
print_check "Build configuration ($JUNGLE_FILE)"
if [ ! -f "$JUNGLE_FILE" ]; then
    print_error "File not found: $JUNGLE_FILE"
else
    print_ok "Found"
fi

# Check private key
PRIVATE_KEY="${PRIVATE_KEY:-.keys/developer_key.der}"
print_check "Developer signing key"
if [ ! -f "$PRIVATE_KEY" ]; then
    print_error "Key not found: $PRIVATE_KEY"
    echo ""
    echo "  Generate a signing key with:"
    echo "    mkdir -p .keys"
    echo "    openssl genrsa -out .keys/developer_key.pem 4096"
    echo "    openssl pkcs8 -topk8 -inform PEM -outform DER \\"
    echo "      -in .keys/developer_key.pem -out .keys/developer_key.der -nocrypt"
elif [ ! -s "$PRIVATE_KEY" ]; then
    print_error "Key file is empty: $PRIVATE_KEY"
else
    print_ok "Found at: $PRIVATE_KEY"
fi

# Check device list
print_check "Supported devices in manifest"
if [ -f "$MANIFEST_FILE" ]; then
    DEVICE_COUNT=$(grep -ic 'product.*id=' "$MANIFEST_FILE" || echo "0")
    if [ "$DEVICE_COUNT" -eq 0 ]; then
        print_error "No devices found in manifest"
    else
        print_ok "Found $DEVICE_COUNT device(s)"
    fi
else
    print_error "Cannot check (manifest missing)"
fi

# Summary
echo ""
printf "${C_BLUE}=== Validation Summary ===${C_RESET}\n\n"

if [ "$ERRORS" -eq 0 ]; then
    printf "${C_GREEN}${OK} All checks passed!${C_RESET}\n\n"
    
    # Print detected configuration
    print_info "Detected Configuration:"
    echo "  SDK: $(basename "${SDK_HOME:-unknown}")"
    if [ -x "$MONKEYC" ]; then
        MONKEYC_VERSION=$("$MONKEYC" --version 2>/dev/null | head -n1 || echo "unknown")
        echo "  Compiler: $MONKEYC_VERSION"
    fi
    if [ -f "$MANIFEST_FILE" ]; then
        DEVICES=$(grep -i 'product.*id=' "$MANIFEST_FILE" | sed -n 's/.*id="\([^"]*\)".*/\1/p' | tr '\n' ' ' || echo "")
        echo "  Devices: $DEVICES"
    fi
    echo ""
    exit 0
else
    printf "${C_RED}${ERR} $ERRORS check(s) failed${C_RESET}\n\n"
    echo "Please fix the issues above before building."
    echo "See BUILD.md or WARP.md for setup instructions."
    echo ""
    exit 1
fi
