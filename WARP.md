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
3. [Project Structure and Architecture](#project-structure-and-architecture)
4. [Common Commands](#common-commands)
5. [Development Workflow](#development-workflow)
6. [Monkey C and Connect IQ Primer](#monkey-c-and-connect-iq-primer)
7. [Device Testing and Simulator](#device-testing-and-simulator)
8. [Testing Strategy](#testing-strategy)
9. [CI/CD and Automation](#cicd-and-automation)
10. [Troubleshooting](#troubleshooting)

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

### Environment Setup (recommended)
```bash
export DEVICE=fenix7
export MONKEYC_KEY="$PWD/.keys/developer_key.der"
```

### Build for Simulator
```bash
mkdir -p bin
monkeyc -f monkey.jungle -d "${DEVICE}" -o bin/garmin_hello_world.prg -y "${MONKEYC_KEY}"
```

### Run in Simulator
```bash
monkeydo bin/garmin_hello_world.prg "${DEVICE}"
```

### Clean Build Artifacts
```bash
rm -rf bin dist
```

### Package for Store (.iq files)
Store packages typically require additional steps via the IDE or SDK packaging utilities:
```bash
mkdir -p dist
# Use IDE or SDK packaging utility to create dist/garmin_hello_world.iq
```

### Testing
Connect IQ lacks standardized unit testing. See the [Testing Strategy](#testing-strategy) section for a pragmatic approach using simulator-driven test harnesses.

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