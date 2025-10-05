# Garmin Hello World App

A simple Hello World application for Garmin smartwatches using the Connect IQ platform.

## Overview

This is a basic Connect IQ watch app that displays "Hello World!" on your Garmin watch. It's designed as a starting point for learning Connect IQ development and includes a complete build chain.

## Features

- ✅ Simple "Hello World" display
- ✅ Works on Forerunner 265, Fenix 7, Epix 2, and Venu 2
- ✅ Proper Connect IQ project structure
- ✅ Build scripts for easy compilation
- ✅ Comprehensive documentation

## Quick Start

### Prerequisites

1. Install Connect IQ SDK Manager from [developer.garmin.com/connect-iq](https://developer.garmin.com/connect-iq)
2. Install Connect IQ SDK and Simulator via SDK Manager
3. Set up environment variables (see [docs/BUILD.md](docs/BUILD.md) for details)

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

After running the Hello World app:

1. Modify the message in `resources/strings/strings.xml`
2. Update the UI in `source/views/MainView.mc`
3. Add new features by extending the delegate and view classes
4. Read WARP.md for comprehensive development guidance

## Resources

- [Connect IQ Documentation](https://developer.garmin.com/connect-iq/)
- [Connect IQ API Reference](https://developer.garmin.com/connect-iq/api-docs/)
- [Garmin Developer Forums](https://forums.garmin.com/developer/)

## License

MIT License - see LICENSE file for details
