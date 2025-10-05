# Implementation Guide - Remaining Phases

This document outlines the remaining implementation phases for completing the test framework and CI/CD setup.

## ✅ COMPLETED (Phases 0-11)

- ✅ Feature branch created
- ✅ Utility modules (StringUtil, MathUtil)  
- ✅ Test framework structure
- ✅ Test helpers (Assert, TestLogger)
- ✅ Comprehensive unit tests (29 test cases)
- ✅ System tests (lifecycle, UI)
- ✅ TestRunner orchestrator
- ✅ TestApp entry point
- ✅ Test manifest and jungle files
- ✅ Test execution scripts (run_tests.sh, parse_test_results.sh)
- ✅ **Test app compiles and is ready to run**

## 📋 Phase 12: Makefile Test Integration

Add to existing `Makefile`:

```makefile
# Test configuration
TEST_JUNGLE ?= monkey.jungle.test
TEST_DEVICE ?= $(DEFAULT_DEVICE)
LOGS_DIR ?= logs

test: validate ## Run test harness
	@printf "$(C_BLUE)[TEST]$(C_RESET) Running test suite...\\n\\n"
	@DEVICE=$(TEST_DEVICE) ./scripts/run_tests.sh

test-all: ## Run tests for all devices
	@for device in $(DEVICES); do \\
		printf "$(C_BLUE)[TEST]$(C_RESET) Testing $$device...\\n"; \\
		DEVICE=$$device ./scripts/run_tests.sh || exit 1; \\
	done

# Update help target to include test commands
```

## 📋 Phase 13: CI Key Generator Script

Create `scripts/generate_ci_key.sh`:

```bash
#!/usr/bin/env bash
# Generate developer key and output base64 for GitHub Secrets

set -euo pipefail

KEYS_DIR=".keys"
KEY_PEM="${KEYS_DIR}/ci_key.pem"
KEY_DER="${KEYS_DIR}/ci_key.der"

mkdir -p "${KEYS_DIR}"

echo "Generating CI developer key..."
openssl genrsa -out "${KEY_PEM}" 4096
openssl pkcs8 -topk8 -inform PEM -outform DER \\
  -in "${KEY_PEM}" -out "${KEY_DER}" -nocrypt

echo ""
echo "=== GitHub Secret Value ==="
echo "Set MONKEYC_KEY_B64 to:"
echo ""
base64 < "${KEY_DER}"
echo ""
echo "=== Cleanup ==="
echo "Delete temporary keys with: rm -rf ${KEYS_DIR}"
```

Make executable: `chmod +x scripts/generate_ci_key.sh`

## 📋 Phase 14-15: GitHub Actions Workflow

Create `.github/workflows/build-and-test.yml`:

```yaml
name: Build and Test

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Cache Connect IQ SDK
        uses: actions/cache@v4
        with:
          path: ~/connectiq-sdk
          key: connectiq-sdk-linux-${{ runner.os }}
      
      - name: Install Dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y xvfb shellcheck
      
      - name: Setup Developer Key
        run: |
          mkdir -p .keys
          echo "${{ secrets.MONKEYC_KEY_B64 }}" | base64 -d > .keys/developer_key.der
      
      - name: Setup SDK
        run: |
          if [ ! -d ~/connectiq-sdk/bin ]; then
            ./scripts/setup_sdk.sh
          fi
          echo "$HOME/connectiq-sdk/bin" >> $GITHUB_PATH
          echo "SDK_HOME=$HOME/connectiq-sdk" >> $GITHUB_ENV
      
      - name: Validate Environment
        run: |
          make validate
          make devices
          make version
      
      - name: Build All Devices
        run: make buildall -j4
      
      - name: Run Tests
        run: make test
      
      - name: Upload Test Logs
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: test-logs
          path: logs/
      
      - name: Upload Build Artifacts
        uses: actions/upload-artifact@v4
        with:
          name: prg-files
          path: bin/*.prg
```

Create `scripts/setup_sdk.sh`:

```bash
#!/usr/bin/env bash
# Download and setup Connect IQ SDK for CI

set -euo pipefail

SDK_URL="${CONNECTIQ_SDK_URL:-https://developer.garmin.com/downloads/connect-iq/sdks/connectiq-sdk-lin-4.2.4-2023-12-06-5b5e4a8ca.zip}"
SDK_DIR="$HOME/connectiq-sdk"

echo "Downloading Connect IQ SDK..."
wget -q "${SDK_URL}" -O /tmp/ciq-sdk.zip

echo "Extracting SDK..."
unzip -q /tmp/ciq-sdk.zip -d /tmp
mv /tmp/connectiq-sdk-* "${SDK_DIR}"

echo "SDK installed to: ${SDK_DIR}"
"${SDK_DIR}/bin/monkeyc" --version
```

Make executable: `chmod +x scripts/setup_sdk.sh`

## 📋 Phases 16-19: Documentation

### TESTING.md (New File)

```markdown
# Testing Guide

## Running Tests Locally

```bash
# Run tests with default device (fr265)
make test

# Run for specific device
DEVICE=fenix7 make test

# Run for all devices
make test-all
```

## Writing Tests

### Unit Tests

Create in `tests/unit/Test<Module>.mc`:

```monkeyc
using <Module>;
using Assert;
using TestLogger;

class TestMyModule {
    function run() {
        var passed = 0;
        var failed = 0;
        passed += testMyFunction();
        return {"passed" => passed, "failed" => failed};
    }
    
    function testMyFunction() {
        TestLogger.logTest("MyModule.myFunction");
        try {
            var result = MyModule.myFunction(input);
            Assert.assertEquals(expected, result, "Should return expected");
            TestLogger.logPass("MyModule.myFunction");
            return 1;
        } catch (ex) {
            TestLogger.logFail("MyModule.myFunction", ex.getErrorMessage());
            return 0;
        }
    }
}
```

Register in `tests/TestRunner.mc`.

### Test Output Markers

- `[TEST]` - Test starting
- `[PASS]` - Test passed
- `[FAIL]` - Test failed
- `[SKIP]` - Test skipped
- `[SUMMARY]` - Overall summary
- `[INFO]` - Informational message

## Troubleshooting

**Tests don't run:**
- Ensure simulator is installed
- Check SDK_HOME is set
- Verify developer key exists

**Tests fail to build:**
- Check Monkey C syntax
- Ensure using `=>` for dictionary literals
- Verify test files are in correct directories
```

### Update README.md

Add sections:

```markdown
## Testing

Run the test suite:

```bash
# Run all tests
make test

# Run for specific device  
DEVICE=fenix7 make test
```

The project includes:
- **29 unit tests** for utility modules
- **4 system tests** for app lifecycle and UI
- Automated test execution with log parsing
- CI/CD integration via GitHub Actions

## CI/CD

The project uses GitHub Actions for continuous integration:
- Builds for all supported devices (fr265, fenix7, epix2, venu2)
- Runs comprehensive test suite
- Archives build artifacts and test logs
- Supports parallel builds for faster execution

[![Build Status](https://github.com/tbrandenburg/garmin_hello_world/workflows/Build%20and%20Test/badge.svg)](https://github.com/tbrandenburg/garmin_hello_world/actions)
```

### Update WARP.md

Replace Testing Strategy section with actual implementation details, CI/CD specifics, and test execution instructions.

##  Phase 20: Quality Gates

```bash
# Clean and rebuild
make clean
make validate

# Build all devices
make buildall -j

# Update .gitignore to include logs/
echo "logs/" >> .gitignore

# Run tests (should pass 100%)
make test

# Run linting if shellcheck available
make lint
```

## Phases 21-22: Push and Deploy

```bash
# Commit remaining work
git add scripts/ .github/ TESTING.md
git commit -m "chore: add test execution scripts and CI/CD workflow"

git add README.md WARP.md
git commit -m "docs: update documentation with test framework and CI details"

# Push branch
git push origin feat/test-framework-and-ci

# Create PR, wait for CI to pass
# Merge to main
```

## Phase 23: Post-Merge

- Monitor first CI runs
- Add GitHub Secret `MONKEYC_KEY_B64` (use generate_ci_key.sh)
- Consider additional tests for 80%+ coverage
- Document any issues as GitHub issues

---

**Current Status:** Phases 0-11 complete, test framework ready, awaiting Makefile integration and CI/CD setup.
