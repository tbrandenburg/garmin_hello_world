# Build Instructions for Hello World App

This document provides instructions for building and running the Garmin Hello World app on your Forerunner 265.

## Prerequisites

Before you can build this app, you need to:

1. **Install Connect IQ SDK Manager**
   - Download from: https://developer.garmin.com/connect-iq/sdk/
   - Install the SDK Manager application

2. **Install Connect IQ SDK**
   - Open SDK Manager
   - Install the latest SDK (e.g., 4.2.x or newer)
   - Note the installation path (e.g., `/Users/YOUR_USERNAME/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-4.2.x`)

3. **Install Connect IQ Simulator**
   - In SDK Manager, install the Connect IQ Simulator
   - Install device profiles including fr265 (Forerunner 265)

4. **Setup Environment Variables**
   Add these to your shell profile (~/.zshrc or ~/.bash_profile):
   ```bash
   export CONNECTIQ_SDK="/path/to/connectiq-sdk-mac-4.2.x"
   export PATH="$PATH:$CONNECTIQ_SDK/bin"
   export MONKEYC_KEY="$PWD/.keys/developer_key.der"
   ```

5. **Reload your shell**
   ```bash
   source ~/.zshrc  # or source ~/.bash_profile
   ```

6. **Verify Installation**
   ```bash
   monkeyc --version
   monkeydo --help
   ```

## Project Structure

The project follows the standard Connect IQ structure:

```
garmin_hello_world/
├── manifest.xml              # App metadata and configuration
├── monkey.jungle             # Build configuration
├── source/
│   ├── App.mc               # Main application class
│   ├── MainDelegate.mc      # Input handling
│   └── views/
│       └── MainView.mc      # UI view
├── resources/
│   ├── resources.xml        # Resource manifest
│   ├── strings/
│   │   └── strings.xml      # Localized strings
│   ├── layouts/
│   │   └── layout.xml       # UI layout
│   └── drawables/
│       ├── drawables.xml    # Drawable definitions
│       └── launcher_icon.png # App icon
└── .keys/
    └── developer_key.der    # Signing key (not committed to git)
```

## Building the App

### Option 1: Build for Forerunner 265 (fr265)

```bash
# Create bin directory if it doesn't exist
mkdir -p bin

# Build the app
monkeyc \
  -f monkey.jungle \
  -d fr265 \
  -o bin/garmin_hello_world.prg \
  -y .keys/developer_key.der
```

### Option 2: Build for Multiple Devices

```bash
# Build for fr265
monkeyc -f monkey.jungle -d fr265 -o bin/garmin_hello_world_fr265.prg -y .keys/developer_key.der

# Build for fenix7
monkeyc -f monkey.jungle -d fenix7 -o bin/garmin_hello_world_fenix7.prg -y .keys/developer_key.der

# Build for venu2
monkeyc -f monkey.jungle -d venu2 -o bin/garmin_hello_world_venu2.prg -y .keys/developer_key.der
```

### Build Script

For convenience, you can use the provided build script:

```bash
# Make it executable (first time only)
chmod +x scripts/build.sh

# Run the build script
./scripts/build.sh
```

## Running in the Simulator

Once the app is built, you can test it in the Connect IQ Simulator:

```bash
# Run on Forerunner 265 simulator
monkeydo bin/garmin_hello_world.prg fr265
```

The simulator will:
1. Launch the Connect IQ Simulator application
2. Install your app on the simulated fr265 device
3. Run the app

### Simulator Controls

- **Back button**: Exit the app
- **Select button**: (Currently just logs to console)

## Testing on Physical Device

To install on your actual Forerunner 265:

1. **Connect your watch** to your computer via USB
2. **Build the app** as shown above
3. **Copy the .prg file** to your watch:
   ```
   /GARMIN/Apps/
   ```
4. **Disconnect** the watch safely
5. **Launch the app** from the watch's app list

## Troubleshooting

### monkeyc not found
- Verify SDK is installed
- Check that PATH includes `$CONNECTIQ_SDK/bin`
- Run `source ~/.zshrc` to reload environment

### Device not found
- Verify device name matches SDK (use `fr265`, not `forerunner265`)
- Check available devices in SDK Manager
- Ensure device profile is installed

### Build errors
- Check that all source files are present
- Verify resources are properly defined
- Review the WARP.md file for detailed troubleshooting

### Signing errors
- Ensure developer_key.der exists in .keys/
- Regenerate key if needed (see WARP.md)

## Packaging for the Connect IQ Store

When you're ready to distribute the app, create an encrypted `.iq` file using the Makefile helper:

```bash
make package
```

This command performs a release build for every supported device and places the signed package in `dist/` with the current semantic version embedded in the filename (e.g., `dist/garmin_hello_world_1.0.0.iq`). Update the root `VERSION` file and the `version` attribute in `manifest.xml` before packaging so the CI validation keeps the metadata synchronized.

## Next Steps

After successfully building and running the Hello World app:

1. **Modify the message**: Edit `resources/strings/strings.xml`
2. **Change the layout**: Modify `resources/layouts/layout.xml`
3. **Add functionality**: Update `source/views/MainView.mc` and `source/MainDelegate.mc`
4. **Learn more**: Read the WARP.md file for comprehensive development guidance

## Resources

- [Connect IQ Documentation](https://developer.garmin.com/connect-iq/overview/)
- [Connect IQ API Reference](https://developer.garmin.com/connect-iq/api-docs/)
- [Connect IQ Programmer's Guide](https://developer.garmin.com/connect-iq/programmers-guide/)
- Project WARP.md file (detailed development guide)
