# Mini Flappy for Garmin

A lightweight Flappy Bird-inspired game for Garmin smartwatches built with the Connect IQ platform.

![20E82F67-CFDA-4BEC-B904-C16F8ACCB0BF](https://github.com/user-attachments/assets/71851cea-1c31-49b8-97d1-54f9af331be9)

## Overview

Steer a tiny bird through an endless stream of pipes using the watch's select button or touch screen. The project is intentionally simple so you can see how to structure a mini-game in Monkey C while still shipping with a complete build chain.

## Features

- ✅ One-button/tap gameplay that mimics Flappy Bird
- ✅ Lightweight game loop that runs entirely inside a single view
- ✅ Works on Forerunner 265, Fenix 7, Epix 2, and Venu 2
- ✅ Proper Connect IQ project structure
- ✅ Build scripts for easy compilation
- ✅ Comprehensive documentation

## Quick Start

### Prerequisites

**Option 1: CLI SDK Manager (Recommended - No GUI Required)**

```bash
# macOS - installs latest SDK by default
./scripts/setup_sdk_macos.sh

# Linux - installs latest SDK by default
./scripts/setup_sdk.sh

# Optional: Pin specific SDK version
# export CONNECTIQ_SDK_VERSION="^7.0.0"  # Or "7.3.1", "latest", etc.

# Add SDK to PATH
export SDK_HOME="$HOME/connectiq-sdk"
export PATH="$SDK_HOME/bin:$PATH"
```

**Option 2: GUI SDK Manager**

1. Install Connect IQ SDK Manager from [developer.garmin.com/connect-iq](https://developer.garmin.com/connect-iq)
2. Install Connect IQ SDK and Simulator via SDK Manager
3. Set up environment variables (see [docs/BUILD.md](docs/BUILD.md) for details)

**See [docs/CI_SETUP.md](docs/CI_SETUP.md) for detailed setup instructions.**

### Building

```bash
# Build for Forerunner 265
./scripts/build.sh fr265

# Or build manually
mkdir -p bin
monkeyc -f monkey.jungle -d fr265 -o bin/garmin_hello_world.prg -y .keys/developer_key.der
```

### Running

```bash
# Run in simulator
monkeydo bin/garmin_hello_world_fr265.prg fr265

# Or copy to your physical watch
# Copy bin/garmin_hello_world_fr265.prg to /GARMIN/Apps/ on your watch
```

## Documentation

- **[docs/CI_SETUP.md](docs/CI_SETUP.md)** - Complete SDK setup guide (CLI Manager, versions, CI/CD) ⭐
- **[docs/BUILD.md](docs/BUILD.md)** - Detailed build and installation instructions
- **[docs/TESTING.md](docs/TESTING.md)** - Testing guide and framework documentation
- **[docs/IMPLEMENTATION_GUIDE.md](docs/IMPLEMENTATION_GUIDE.md)** - Technical implementation details
- **[WARP.md](WARP.md)** - Comprehensive development guide for Connect IQ
- **resources/drawables/README.md** - Information about the launcher icon

## Project Structure

```
garmin_hello_world/
├── manifest.xml              # App metadata and configuration
├── monkey.jungle             # Build configuration
├── source/                   # Source code
│   ├── App.mc               # Main application class
│   ├── MainDelegate.mc      # Input handling
│   └── views/
│       └── MainView.mc      # UI view
├── resources/               # Resources (strings, layouts, images)
│   ├── resources.xml
│   ├── strings/
│   ├── layouts/
│   └── drawables/
├── scripts/                 # Build and utility scripts
└── .keys/                   # Developer signing keys (not in git)
```

## Supported Devices

- Forerunner 265 (fr265)
- Fenix 7 (fenix7)
- Epix 2 (epix2)
- Venu 2 (venu2)

## Next Steps

After playing a few rounds:

1. Tweak physics constants in `source/views/MainView.mc` to change the game's difficulty.
2. Replace the simple graphics with sprite sheets or vector art using the `resources/drawables/` folder.
3. Expand the game loop with bonus pickups, high score persistence, or vibration feedback in `MainDelegate.mc`.
4. Read WARP.md for comprehensive development guidance.

## Resources

- [Connect IQ Documentation](https://developer.garmin.com/connect-iq/)
- [Connect IQ API Reference](https://developer.garmin.com/connect-iq/api-docs/)
- [Garmin Developer Forums](https://forums.garmin.com/developer/)

## License

MIT License - see LICENSE file for details
