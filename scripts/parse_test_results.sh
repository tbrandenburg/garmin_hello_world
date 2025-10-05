#!/usr/bin/env bash
# parse_test_results.sh - Parse test output and determine pass/fail
# Looks for [TEST], [PASS], [FAIL], [SKIP], [SUMMARY] markers

set -euo pipefail

LOG_FILE="${1:-}"

if [[ -z "${LOG_FILE}" ]] || [[ ! -f "${LOG_FILE}" ]]; then
    echo "Usage: $0 <log_file>" >&2
    exit 1
fi

# Colors for TTY output
if [[ -t 1 ]]; then
    C_RED='\033[0;31m'
    C_GREEN='\033[0;32m'
    C_YELLOW='\033[0;33m'
    C_BLUE='\033[0;34m'
    C_BOLD='\033[1m'
    C_RESET='\033[0m'
else
    C_RED=''
    C_GREEN=''
    C_YELLOW=''
    C_BLUE=''
    C_BOLD=''
    C_RESET=''
fi

# Count markers in log
TEST_COUNT=$(grep -c '^\[TEST\]' "${LOG_FILE}" || true)
PASS_COUNT=$(grep -c '^\[PASS\]' "${LOG_FILE}" || true)
FAIL_COUNT=$(grep -c '^\[FAIL\]' "${LOG_FILE}" || true)
SKIP_COUNT=$(grep -c '^\[SKIP\]' "${LOG_FILE}" || true)

# Look for summary line
SUMMARY_LINE=$(grep '^\[SUMMARY\]' "${LOG_FILE}" || true)

# Extract from summary if present
if [[ -n "${SUMMARY_LINE}" ]]; then
    # Parse: [SUMMARY] Total: X, Passed: Y, Failed: Z, Skipped: W
    SUMMARY_TOTAL=$(echo "${SUMMARY_LINE}" | sed -n 's/.*Total: \([0-9]*\).*/\1/p')
    SUMMARY_PASSED=$(echo "${SUMMARY_LINE}" | sed -n 's/.*Passed: \([0-9]*\).*/\1/p')
    SUMMARY_FAILED=$(echo "${SUMMARY_LINE}" | sed -n 's/.*Failed: \([0-9]*\).*/\1/p')
    SUMMARY_SKIPPED=$(echo "${SUMMARY_LINE}" | sed -n 's/.*Skipped: \([0-9]*\).*/\1/p')
fi

# Print results
echo ""
echo -e "${C_BOLD}${C_BLUE}=== Test Results ===${C_RESET}"
echo ""
echo -e "Tests Run:    ${C_BOLD}${TEST_COUNT}${C_RESET}"
echo -e "Passed:       ${C_GREEN}${PASS_COUNT}${C_RESET}"
echo -e "Failed:       ${C_RED}${FAIL_COUNT}${C_RESET}"
echo -e "Skipped:      ${C_YELLOW}${SKIP_COUNT}${C_RESET}"
echo ""

# Show summary line if found
if [[ -n "${SUMMARY_LINE}" ]]; then
    echo -e "${C_BOLD}Summary from test harness:${C_RESET}"
    echo "${SUMMARY_LINE}"
    echo ""
fi

# Validate consistency
EXPECTED_OUTCOMES=$((PASS_COUNT + FAIL_COUNT + SKIP_COUNT))
if [[ ${TEST_COUNT} -ne ${EXPECTED_OUTCOMES} ]]; then
    echo -e "${C_YELLOW}[WARNING]${C_RESET} Test count mismatch: ${TEST_COUNT} tests but ${EXPECTED_OUTCOMES} outcomes"
    echo ""
fi

# Show failed tests if any
if [[ ${FAIL_COUNT} -gt 0 ]]; then
    echo -e "${C_BOLD}${C_RED}Failed Tests:${C_RESET}"
    echo ""
    grep '^\[FAIL\]' "${LOG_FILE}" || true
    echo ""
fi

# Determine exit code
if [[ ${FAIL_COUNT} -eq 0 ]] && [[ ${TEST_COUNT} -gt 0 ]]; then
    echo -e "${C_GREEN}${C_BOLD}✓ All tests passed!${C_RESET}"
    echo ""
    exit 0
elif [[ ${TEST_COUNT} -eq 0 ]]; then
    echo -e "${C_RED}${C_BOLD}✗ No tests found in output${C_RESET}"
    echo ""
    exit 2
else
    echo -e "${C_RED}${C_BOLD}✗ ${FAIL_COUNT} test(s) failed${C_RESET}"
    echo ""
    exit 1
fi
