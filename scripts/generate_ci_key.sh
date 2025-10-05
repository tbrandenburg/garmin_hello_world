#!/usr/bin/env bash
# generate_ci_key.sh - Generate developer key for CI and output base64 for GitHub Secrets

set -euo pipefail

KEYS_DIR=".keys"
KEY_PEM="${KEYS_DIR}/ci_key.pem"
KEY_DER="${KEYS_DIR}/ci_key.der"

mkdir -p "${KEYS_DIR}"

echo "Generating CI developer key..."
openssl genrsa -out "${KEY_PEM}" 4096
openssl pkcs8 -topk8 -inform PEM -outform DER \
  -in "${KEY_PEM}" -out "${KEY_DER}" -nocrypt

echo ""
echo "=========================================="
echo "GitHub Secret Value"
echo "=========================================="
echo ""
echo "Set MONKEYC_KEY_B64 in GitHub Secrets to:"
echo ""
base64 < "${KEY_DER}"
echo ""
echo "=========================================="
echo "Cleanup"
echo "=========================================="
echo ""
echo "After adding the secret to GitHub, delete temporary keys:"
echo "  rm -rf ${KEYS_DIR}/ci_key.*"
echo ""
echo "Keep your existing developer_key.der for local builds."
echo ""
