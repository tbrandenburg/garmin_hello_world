# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

# Garmin Connect IQ Hello World App

This repository contains a Hello World application for Garmin smartwatches using the Connect IQ platform, including a complete build chain and development workflow.

## Project Configuration

- **App type**: watch-app (interactive)
- **Minimum Connect IQ SDK**: 4.2.x (supports modern devices)
- **Primary test devices**: fenix7, epix2, venu2, fr265, vivoactive4
- **Namespace**: com.example.garmin.helloworld
- **App name**: Garmin Hello World

## Table of Contents

1. [TL;DR Quick Start](#tldr-quick-start)
2. [Development Environment Setup](#development-environment-setup)
3. [**Makefile Build System**](#makefile-build-system) ⭐ **NEW**
4. [Project Structure and Architecture](#project-structure-and-architecture)
5. [Common Commands](#common-commands)
6. [Development Workflow](#development-workflow)
7. [Monkey C and Connect IQ Primer](#monkey-c-and-connect-iq-primer)
8. [Device Testing and Simulator](#device-testing-and-simulator)
9. [Testing Strategy](#testing-strategy)
10. [CI/CD and Automation](#cicd-and-automation)
11. [Troubleshooting](#troubleshooting)

## TL;DR Quick Start

### 1. Install Connect IQ SDK Manager and Tools
- Download the SDK Manager from [developer.garmin.com/connect-iq](https://developer.garmin.com/connect-iq)
- Use it to install:
  - Latest Connect IQ SDK (e.g., 4.2.x)
  - Connect IQ Simulator
  - Target devices (e.g., fenix7, venu2)

### 2. Configure Environment
Add SDK bin to PATH:
```bash
export CONNECTIQ_SDK=/path/to/connectiq-sdk-mac-4.2.x
export PATH="$PATH:$CONNECTIQ_SDK/bin"
```

### 3. Generate Developer Signing Key
```bash
mkdir -p .keys
openssl genrsa -out .keys/developer_key.pem 4096
openssl pkcs8 -topk8 -inform PEM -outform DER -in .keys/developer_key.pem -out .keys/developer_key.der -nocrypt
```

### 4. Build and Run (after project files exist)
```bash
mkdir -p bin
monkeyc -f monkey.jungle -d fenix7 -o bin/garmin_hello_world.prg -y .keys/developer_key.der
monkeydo bin/garmin_hello_world.prg fenix7
```

## Development Environment Setup

### Prerequisites
- **Connect IQ SDK Manager**: Downloads and manages SDKs and the Simulator
- **Connect IQ SDK**: Version 4.2.x or later for modern device support
- **Connect IQ Simulator**: Device testing and debugging
- **OpenSSL**: For developer key generation
- **Optional**: VS Code + Garmin Connect IQ extension (recommended over Eclipse-based IDE)

### Environment Variables
Set these in your shell profile:
```bash
export CONNECTIQ_SDK=/path/to/connectiq-sdk-mac-4.2.x
export PATH="$PATH:$CONNECTIQ_SDK/bin"
export MONKEYC_KEY="$PWD/.keys/developer_key.der"
```

### Verify Installation
```bash
monkeyc --version
monkeydo --help
```

### Finding Device IDs
- The simulator's Devices panel lists all installed devices
- Device tokens match folders under `$CONNECTIQ_SDK/devices/` (e.g., fenix7, epix2, venu2)

## Makefile Build System

This project uses a **professional Makefile-based build system** following industry best practices from successful Connect IQ open-source projects.

### Why Makefile?

✅ **Benefits:**
- Smart SDK autodetection (no environment variables required)
- Parallel builds for multiple devices (`make buildall -j`)
- Dependency tracking (only rebuilds when files change)
- Environment validation before builds
- Colored, professional output
- CI/CD ready
- IDE-friendly (works with VS Code, vim, etc.)

### Quick Reference

```bash
# Show all available commands
make help

# Validate your environment
make validate

# Build for default device (fr265)
make build

# Build for specific device
make build DEVICE=fenix7

# Build for all devices (parallel)
make buildall -j4

# Build and run in simulator
make run DEVICE=epix2

# Build optimized releases
make release -j4

# Create store package
make package

# List supported devices
make devices

# Show SDK and tool versions
make version

# Clean build artifacts
make clean

# Run all diagnostics
make doctor
```

### Build Targets

| Target | Description |
|--------|-------------|
| `help` | Show available targets and examples |
| `validate` | Check SDK, tools, keys, and project files |
| `devices` | List all supported devices from manifest |
| `version` | Display SDK and compiler versions |
| `build` | Build for single device (use DEVICE=...) |
| `buildall` | Build for all devices (supports -j for parallel) |
| `run` | Build and launch in simulator |
| `release` | Build optimized releases for all devices |
| `package` | Create store-ready .iq packages |
| `test` | Run test harness (when tests exist) |
| `clean` | Remove all build artifacts |
| `doctor` | Run full environment diagnostics |
| `lint` | Run shellcheck on scripts (if available) |

### Build Variables

Customize builds with these variables:

```bash
# Target device (default: fr265)
make build DEVICE=venu2

# Build mode: debug or release (default: debug)
make build BUILD_MODE=release

# Parallel jobs (default: auto-detected CPU count)
make buildall -j8
```

### Configuration Files

**`config.mk`** - Default build configuration
- SDK autodetection
- Compiler flags
- Default devices
- Color schemes

**`properties.mk` (optional)** - User-specific overrides
- Create from `properties.mk.example`
- Not tracked in git
- Useful for team-specific settings

```bash
# Create custom configuration
cp properties.mk.example properties.mk
# Edit properties.mk with your preferences
```

**Example `properties.mk`:**
```makefile
# Force specific SDK path
SDK_HOME := /Users/you/ConnectIQ/Sdks/connectiq-sdk-mac-8.3.0

# Use different default device
DEFAULT_DEVICE := fenix7

# Custom parallel jobs
JOBS := 8
```

### Smart SDK Autodetection

The build system automatically finds your SDK in this order:

1. `$CONNECTIQ_SDK` environment variable (if set)
2. `~/Library/Application Support/Garmin/ConnectIQ/Sdks/` (macOS)
3. `/Applications/Garmin/ConnectIQ/Sdks/` (macOS)
4. `~/connectiq-sdk*` (generic)

**To verify detection:**
```bash
make version
# Shows: SDK Home, App Name, Compiler version
```

### Environment Validation

Before any build, the system validates:
- ✓ SDK installation and paths
- ✓ Compiler and simulator tools
- ✓ Developer signing key
- ✓ Project files (manifest, jungle)
- ✓ Device list from manifest

```bash
make validate
# Outputs detailed validation report with colored status
```

### Parallel Builds

Build for all devices simultaneously:

```bash
# Auto-detect CPU cores
make buildall -j

# Specify job count
make buildall -j4

# Silent parallel build
make buildall -j4 2>&1 | grep -E "SUCCESS|ERROR"
```

**Build times (4 devices):**
- Sequential: ~20-30 seconds
- Parallel (-j4): ~8-10 seconds

### Dependency Tracking

Builds automatically rebuild when these change:
- ✓ Any `.mc` source file
- ✓ Any resource file (XML, images, strings)
- ✓ `manifest.xml`
- ✓ `monkey.jungle`

**Incremental builds:**
```bash
# First build: ~8 seconds
make build

# No changes: instant
make build

# After editing MainView.mc: ~8 seconds
make build
```

### CI/CD Integration

**GitHub Actions Example:**
```yaml
name: Build
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      # Setup SDK (cache for speed)
      - name: Cache Connect IQ SDK
        uses: actions/cache@v4
        with:
          path: ~/connectiq-sdk
          key: ciq-sdk-${{ runner.os }}
      
      # Restore signing key from secrets
      - name: Setup Developer Key
        run: |
          mkdir -p .keys
          echo "${{ secrets.MONKEYC_KEY_B64 }}" | base64 -d > .keys/developer_key.der
      
      # Validate environment
      - name: Validate
        run: make validate
      
      # Build all devices
      - name: Build All
        run: make buildall -j$(nproc)
      
      # Upload artifacts
      - name: Upload Builds
        uses: actions/upload-artifact@v4
        with:
          name: build-artifacts
          path: bin/*.prg
```

### Troubleshooting Build Issues

**SDK Not Found:**
```bash
# Check SDK detection
make version

# Set SDK manually in properties.mk
echo "SDK_HOME := /path/to/sdk" > properties.mk
make validate
```

**Compiler Errors:**
```bash
# Check compiler path
which monkeyc

# Verify SDK installation
ls "$SDK_HOME/bin/"

# Run validation
make doctor
```

**Key Issues:**
```bash
# Generate new key
openssl genrsa -out .keys/developer_key.pem 4096
openssl pkcs8 -topk8 -inform PEM -outform DER \
  -in .keys/developer_key.pem -out .keys/developer_key.der -nocrypt

# Verify key exists
make validate | grep "signing key"
```

**Build Artifacts Not Updating:**
```bash
# Force clean rebuild
make clean
make build

# Check file timestamps
ls -lt source/*.mc bin/*.prg
```

### Migration from scripts/build.sh

The old `scripts/build.sh` is **deprecated** but still works:

```bash
# Old way (deprecated)
./scripts/build.sh fenix7

# New way (recommended)
make build DEVICE=fenix7
```

**The old script now forwards to Make and shows a deprecation notice.**

### Advanced Usage

**Custom Compiler Flags:**
```makefile
# In properties.mk
DEBUG_FLAGS := -w -g
RELEASE_FLAGS := -w -r -O3pz
```

**Build Specific Device:**
```bash
# Just one device
make bin/garmin_hello_world_fenix7.prg
```

**Conditional Builds:**
```bash
# Build only if validation passes
make validate && make buildall -j
```

**Custom App Name:**
```makefile
# In properties.mk
APP_NAME := my_custom_name
# Outputs: bin/my_custom_name_fenix7.prg
```

## Project Structure and Architecture

### Expected File Structure
```
garmin_hello_world/
├── README.md
├── WARP.md
├── LICENSE
├── .gitignore
├── manifest.xml          # App metadata, SDK requirements, permissions
├── monkey.jungle          # Build configuration
├── .keys/                 # Developer keys (excluded from git)
├── bin/                   # Build output (.prg files, ignored)
├── dist/                  # Store packages (.iq files, ignored)
├── source/
│   ├── App.mc            # Main app class (extends Toybox.App.AppBase)
│   ├── MainDelegate.mc   # App delegate (UI event handling)
│   ├── views/
│   │   └── MainView.mc   # Main view (extends Toybox.WatchUi.View)
│   └── util/             # Pure logic helpers (easier to test)
├── resources/
│   ├── resources.xml     # Resource manifest
│   ├── strings/
│   │   └── strings.xml   # Localized strings
│   ├── layouts/
│   │   └── layout.xml    # UI layouts
│   └── images/
│       └── icon.png      # App icon (multiple resolutions)
├── tests/                # Simulator-driven test harness (optional)
└── scripts/              # Build/run/test helpers (optional)
```

### Architecture Overview

**Application Entry Points:**
- `App.mc`: Defines the App class with lifecycle methods (onStart, onStop, getInitialView)
- `MainDelegate.mc`: Controls app flow and responds to UI events and timers
- `MainView.mc`: Handles UI rendering (onUpdate, onShow, onHide)

**Best Practices:**
- Decouple business logic from Views to enable easier testing
- Place pure logic in `source/util/` modules with minimal Toybox dependencies
- Use `resources.xml` to reference images, strings, and layouts
- Define device-specific layouts using resource qualifiers

**Manifest Configuration:**
- Specifies app type (watch-app, watchface, widget, data field)
- Sets minSdkVersion, permissions, and product ID
- Lists supported devices and features

## Common Commands

**Note:** This project uses a Makefile build system. See the [Makefile Build System](#makefile-build-system) section for comprehensive details.

### Quick Commands (Makefile - Recommended)

```bash
# Build for default device (fr265)
make build

# Build for specific device
make build DEVICE=fenix7

# Build and run in simulator
make run DEVICE=epix2

# Build for all devices (parallel)
make buildall -j4

# Build optimized releases
make release -j4

# Clean build artifacts
make clean

# Show all available commands
make help
```

### Legacy Commands (Direct monkeyc)

These still work but Makefile is recommended:

```bash
# Environment setup
export DEVICE=fenix7
export MONKEYC_KEY="$PWD/.keys/developer_key.der"

# Build
mkdir -p bin
monkeyc -f monkey.jungle -d "${DEVICE}" \
  -o bin/garmin_hello_world.prg \
  -y "${MONKEYC_KEY}"

# Run in simulator
monkeydo bin/garmin_hello_world.prg "${DEVICE}"

# Clean
rm -rf bin dist
```

### Package for Store (.iq files)

```bash
# Using Makefile (recommended)
make package

# Or use SDK packaging directly
monkeyc -f monkey.jungle -e -r \
  -o dist/garmin_hello_world.iq \
  -y .keys/developer_key.der
```

### Testing

```bash
# Run test harness (when implemented)
make test

# Run full diagnostics
make doctor
```

See the [Testing Strategy](#testing-strategy) section for implementation details.

## Development Workflow

### Branching Strategy
- Use descriptive branch names: `type/scope-description`
- Examples: `docs/add-warp-md`, `feat/clock-draw`, `fix/crash-on-start`
- Keep PRs small and focused on a single logical change

### Pre-commit Checklist
- [ ] Build successfully for at least one target device
- [ ] Run simulator smoke test
- [ ] Execute test suite if tests exist
- [ ] Ensure working tree is clean (no build artifacts committed)

### Security and Keys
- **Never commit `.keys/` directory or developer keys**
- Store `MONKEYC_KEY` as a secure secret in CI environments
- Regenerate keys if accidentally exposed

### Code Quality Guidelines
- Prefer small, pure utility functions in `source/util/`
- Keep UI code thin; push business logic to utility modules
- Use `System.println()` for meaningful debugging output
- Test on multiple devices early to catch layout issues

### Repository Hygiene
Ensure `.gitignore` excludes:
```gitignore
# Connect IQ build artifacts
bin/
dist/
build/
target/
*.prg
*.iq

# IDE and system files
.settings/
.project
.classpath
.vscode/
.DS_Store

# Developer keys (critical)
.keys/
```

### Post-development Testing
- Build for primary device set (fenix7, venu2, epix2)
- Test on simulator with various settings:
  - Light/dark mode
  - 12/24-hour time format
  - Metric/imperial units
  - Different screen sizes and shapes

## Monkey C and Connect IQ Primer

### Monkey C Language
- **Syntax**: Statically typed, C/Java-like syntax
- **Features**: Classes, modules, interfaces, garbage collection
- **Standard Library**: Limited; use Toybox modules for platform APIs

### Key Toybox Modules
- **Toybox.App**: Application lifecycle management
- **Toybox.WatchUi**: Views, input handling, drawing lifecycle
- **Toybox.Graphics**: Drawing primitives (fonts, colors, shapes)
- **Toybox.System**: App info, logging, timers, locale settings
- **Toybox.Sensor/SensorHistory**: HR, steps, GPS data (requires permissions)
- **Toybox.Time**: Time and date utilities
- **Toybox.Activity**: Activity and fitness data access
- **Toybox.Communications**: Network requests (requires permissions)

### Application Lifecycle (watch-app)
```monkeyc
class MyApp extends App.AppBase {
    function onStart() { /* App initialization */ }
    function onStop() { /* Cleanup */ }
    function onExit() { /* Final cleanup */ }
    function getInitialView() { return [ new MyView() ]; }
}

class MyView extends WatchUi.View {
    function onShow() { /* View setup */ }
    function onHide() { /* View cleanup */ }
    function onUpdate() { /* Rendering logic */ }
}
```

### Performance Considerations
- **Memory Management**: Avoid heavy allocations in `onUpdate()`; reuse objects
- **Battery Efficiency**: Minimize per-second operations and CPU-intensive tasks
- **Resource Optimization**: Use device-appropriate fonts and image resolutions
- **Localization**: Prefer string resources over hardcoded text

## Device Testing and Simulator

### Launching the Simulator
1. Start the Connect IQ Simulator (installed via SDK Manager)
2. Select target device (must match your build `DEVICE` variable)
3. Ensure device profiles match available SDK devices

### Running Applications
```bash
monkeydo bin/garmin_hello_world.prg fenix7
```
The simulator installs and launches the app on the selected device profile.

### Debugging and Logs
- **Log Panel**: Use the simulator's Log panel for debugging output
- **Logging**: Add `System.println("debug message")` in your code
- **Exception Handling**: Monitor for exceptions and stack traces in logs

### Simulation Features
Test various scenarios:
- **Sensor Data**: GPS, heart rate, steps, movement
- **Time Changes**: Different time zones, 12/24-hour formats
- **Watch Settings**: Units (metric/imperial), color themes
- **Device Variations**: Screen sizes, shapes, capabilities

### Multi-device Testing
- Test early and often on different device profiles
- Pay attention to screen geometry differences (round vs. rectangular)
- Use resource qualifiers for device-specific layouts

### Simulator Tips
- If app doesn't update after rebuild, stop and restart the app
- Clear app data between test runs to avoid state confusion
- Use the simulator's input simulation for button presses and gestures

## Testing Strategy

### Reality Check
Connect IQ lacks official unit testing and code coverage tools. Our strategy focuses on:
- **Logic Isolation**: Business logic in `source/util/` with minimal Toybox dependencies
- **Simulator-driven Testing**: Custom test harness that logs PASS/FAIL results
- **Manual UI Verification**: Visual testing in the simulator

### Test Harness Structure (Optional)
```
tests/
├── TestRunner.mc       # Entry point that orchestrates test execution
├── test_util_math.mc   # Tests for utility modules
└── test_util_format.mc # More utility tests
```

### Testing Conventions
- Log test results with standard prefixes: `[TEST]`, `[PASS]`, `[FAIL]`, `[SKIP]`
- Parse simulator logs to determine test success/failure
- Exit with non-zero code if any tests fail

### Example Test Command
```bash
DEVICE=${DEVICE:-fenix7}
mkdir -p bin
# Build test-enabled variant
monkeyc -f monkey.jungle -d "${DEVICE}" -o bin/tests.prg -y "${MONKEYC_KEY}"
# Run and capture logs
monkeydo bin/tests.prg "${DEVICE}" | tee .last-test.log
# Parse results (implement scripts/parse_tests.sh)
scripts/parse_tests.sh .last-test.log
```

### Coverage Expectations
- **Target**: 80%+ coverage of non-UI logic
- **Tracking**: Manual checklist or coverage.md until better tooling available
- **Focus**: Black-box testing of utility functions
- **Avoid**: Complex UI assertions; prefer visual verification

## CI/CD and Automation

### Automation Goals
- SDK and Simulator installation (or cached runner images)
- Build verification for multiple target devices
- Automated test execution with log parsing
- Artifact archival (`.prg` files, store packages)

### GitHub Actions Example
```yaml
name: ciq-build-and-test
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      # Cache SDK installation
      - name: Cache Connect IQ SDK
        uses: actions/cache@v4
        with:
          path: ~/connectiq-sdk
          key: connectiq-sdk-4.2.x
      
      # Setup environment
      - name: Setup SDK
        run: |
          echo "CONNECTIQ_SDK=$HOME/connectiq-sdk" >> $GITHUB_ENV
          echo "$HOME/connectiq-sdk/bin" >> $GITHUB_PATH
      
      # Restore developer key from secrets
      - name: Setup developer key
        run: |
          mkdir -p .keys
          echo "${{ secrets.MONKEYC_KEY_B64 }}" | base64 -d > .keys/developer_key.der
      
      # Build for primary devices
      - name: Build (fenix7)
        run: |
          mkdir -p bin
          monkeyc -f monkey.jungle -d fenix7 -o bin/garmin_hello_world.prg -y .keys/developer_key.der
      
      # Run tests if harness exists
      - name: Run tests
        run: |
          if [ -f tests/TestRunner.mc ]; then
            monkeydo bin/garmin_hello_world.prg fenix7 | tee .last-test.log
            scripts/parse_tests.sh .last-test.log
          fi
      
      # Archive build artifacts
      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: prg-files
          path: bin/*.prg
```

### CI Security
- Store `MONKEYC_KEY` as base64-encoded GitHub secret
- Never expose developer keys in logs or artifacts
- Use separate keys for CI vs. production/store builds

### Headless Testing Notes
Headless simulator support varies by OS and SDK version. If full GUI testing isn't feasible on hosted runners:
- Focus on build verification
- Use self-hosted runners with display support for full testing
- Consider containerized solutions with virtual displays

## Troubleshooting

### Common Issues and Solutions

**`monkeyc not found`**
- Ensure `$CONNECTIQ_SDK/bin` is in your `PATH`
- Verify with `monkeyc --version`

**Device name mismatch errors**
- Use exact device tokens from SDK (e.g., `fenix7` not `fenix7s`)
- Check available devices in simulator's device list
- Verify device folders exist under `$CONNECTIQ_SDK/devices/`

**Signing/key errors**
- Confirm `MONKEYC_KEY` points to a valid DER-encoded private key
- Regenerate keys if corrupted:
  ```bash
  openssl genrsa -out .keys/developer_key.pem 4096
  openssl pkcs8 -topk8 -inform PEM -outform DER -in .keys/developer_key.pem -out .keys/developer_key.der -nocrypt
  ```

**Simulator doesn't refresh after rebuild**
- Stop the app in the simulator and rerun `monkeydo`
- If persistent, close and reopen the simulator entirely
- Check for background processes holding file locks

**Resource/layout issues across devices**
- Test on multiple device profiles early in development
- Use resource qualifiers for device-specific assets
- Implement adaptive layouts for different screen geometries

**Performance problems**
- Profile memory allocation patterns in `onUpdate()`
- Reuse drawing resources and object buffers
- Minimize per-frame computational work

### Additional Resources
- [Connect IQ Documentation](https://developer.garmin.com/connect-iq)
- Connect IQ Device Capability Matrices in SDK documentation
- SDK sample applications and code examples
- Garmin Developer Forums for community support

---

**Note**: This repository is currently a starter template. The actual Connect IQ application files (manifest.xml, monkey.jungle, source/, resources/) will be added as development progresses. This WARP.md file will be updated to reflect any project-specific conventions and patterns that emerge.