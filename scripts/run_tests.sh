#!/usr/bin/env bash
# run_tests.sh - Build and execute test harness
# Runs tests in simulator and captures output for parsing

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Configuration
DEVICE="${DEVICE:-fr265}"
TEST_JUNGLE="${PROJECT_ROOT}/monkey.jungle.test"
TEST_MANIFEST="${PROJECT_ROOT}/manifest.test.xml"
BIN_DIR="${PROJECT_ROOT}/bin"
LOGS_DIR="${PROJECT_ROOT}/logs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${LOGS_DIR}/test_${DEVICE}_${TIMESTAMP}.log"

# Colors for output
if [[ -t 1 ]]; then
    C_RED='\033[0;31m'
    C_GREEN='\033[0;32m'
    C_YELLOW='\033[0;33m'
    C_BLUE='\033[0;34m'
    C_RESET='\033[0m'
else
    C_RED=''
    C_GREEN=''
    C_YELLOW=''
    C_BLUE=''
    C_RESET=''
fi

# Print with color
print_info() {
    echo -e "${C_BLUE}[INFO]${C_RESET} $*"
}

print_success() {
    echo -e "${C_GREEN}[SUCCESS]${C_RESET} $*"
}

print_error() {
    echo -e "${C_RED}[ERROR]${C_RESET} $*" >&2
}

print_warning() {
    echo -e "${C_YELLOW}[WARNING]${C_RESET} $*"
}

# Ensure logs directory exists
mkdir -p "${LOGS_DIR}"

# Ensure simulator is running (macOS only)
if [[ "$(uname)" == "Darwin" ]]; then
    if [[ -f "${SCRIPT_DIR}/ensure_simulator.sh" ]]; then
        if ! "${SCRIPT_DIR}/ensure_simulator.sh"; then
            print_warning "Failed to start simulator automatically"
            print_warning "Please ensure Connect IQ Simulator is running manually"
        fi
        echo ""
    fi
fi

print_info "Running tests for device: ${DEVICE}"
print_info "Log file: ${LOG_FILE}"
echo ""

# Build test app
print_info "Building test application..."
cd "${PROJECT_ROOT}"

if [[ -n "${SDK_HOME:-}" ]]; then
    MONKEYC="${SDK_HOME}/bin/monkeyc"
    MONKEYDO="${SDK_HOME}/bin/monkeydo"
else
    MONKEYC="monkeyc"
    MONKEYDO="monkeydo"
fi

# Check if tools exist
if ! command -v "${MONKEYC}" &> /dev/null; then
    print_error "monkeyc not found. Please set SDK_HOME or add SDK to PATH."
    exit 1
fi

# Build test app
TEST_PRG="${BIN_DIR}/test_${DEVICE}.prg"
mkdir -p "${BIN_DIR}"

if "${MONKEYC}" -f "${TEST_JUNGLE}" -d "${DEVICE}" -o "${TEST_PRG}" -y .keys/developer_key.der -w 2>&1 | tee "${LOG_FILE}.build"; then
    print_success "Test app built successfully"
else
    print_error "Test build failed"
    cat "${LOG_FILE}.build"
    exit 1
fi

echo ""

# Run test app in simulator
print_info "Running tests in simulator..."
echo ""

# Check if we need to use xvfb (headless environment)
if [[ -z "${DISPLAY:-}" ]] && command -v xvfb-run &> /dev/null; then
    print_warning "No DISPLAY detected, using xvfb-run for headless execution"
    RUN_CMD="xvfb-run -a ${MONKEYDO}"
else
    RUN_CMD="${MONKEYDO}"
fi

# Run tests and capture output
if ${RUN_CMD} "${TEST_PRG}" "${DEVICE}" 2>&1 | tee "${LOG_FILE}"; then
    SIMULATOR_EXIT=0
else
    SIMULATOR_EXIT=$?
fi

echo ""
print_info "Test execution complete, parsing results..."
echo ""

# Parse test results
if "${SCRIPT_DIR}/parse_test_results.sh" "${LOG_FILE}"; then
    print_success "All tests passed!"
    exit 0
else
    EXIT_CODE=$?
    print_error "Tests failed (exit code: ${EXIT_CODE})"
    exit "${EXIT_CODE}"
fi
