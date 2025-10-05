# Connect IQ SDK Version Compatibility

## Issue: Builds Work Locally But Fail in CI

### Root Cause

Connect IQ SDK **device identifiers changed between SDK versions**, specifically between SDK 7.x and SDK 8.x.

### Environment Comparison

| Environment | SDK Version | Device IDs Status |
|-------------|-------------|-------------------|
| **Local Mac** | 8.3.0 | ✅ `fr265`, `fenix7`, `epix2`, `venu2` all work |
| **GitHub CI (before fix)** | 7.x | ❌ These device IDs don't exist in SDK 7.x |
| **GitHub CI (after fix)** | 8.x | ✅ Matches local environment |

### Device Locations by Platform

**macOS:**
- SDK: `~/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-X.Y.Z/`
- Devices: `~/Library/Application Support/Garmin/ConnectIQ/Devices/`

**Linux (CI):**
- SDK: `~/connectiq-sdk/`
- Devices: `~/connectiq-sdk/devices/` or `~/.Garmin/ConnectIQ/devices/`

### The Fix (Part 1: SDK Version)

Updated `.github/workflows/build-and-test.yml` to use SDK 8.x:

```yaml
env:
  # Changed from ^7.0.0 to ^8.0.0
  CONNECTIQ_SDK_VERSION: "^8.0.0"
```

This ensures CI uses the same SDK version as local development.

### The Fix (Part 2: Device Downloads)

**Additional Discovery:** The Connect IQ CLI SDK Manager downloads **SDKs and devices separately**!

Even with SDK 8.3.0 installed, builds were still failing with:
```
ERROR: Invalid device id specified: 'fenix7'.
```

Because the devices directory was **empty**. The CLI SDK Manager requires explicit device installation.

**Updated setup scripts** to include device downloads:

```bash
# Download each required device
for device in fr265 fenix7 epix2 venu2; do
    /tmp/connect-iq-sdk-manager device install "${device}"
done
```

Now the setup scripts:
1. Install SDK Manager CLI
2. Accept license
3. Login to Garmin
4. Download SDK (e.g., 8.3.0)
5. **Download devices** (NEW!)
6. Create symlink
7. **Verify devices installed** (NEW!)

### Verifying Device Availability

**On macOS:**
```bash
ls -1 "$HOME/Library/Application Support/Garmin/ConnectIQ/Devices/" | grep -E "(fr265|fenix7|epix2|venu2)"
```

**On Linux/CI:**
```bash
ls -1 "$SDK_HOME/devices/" | grep -E "(fr265|fenix7|epix2|venu2)"
```

### Device ID Changes Across SDK Versions

The Connect IQ SDK has evolved device naming over time:

- **SDK 4.x**: Used simple names like `fenix5`, `fr235`
- **SDK 7.x**: Some device names changed or were removed
- **SDK 8.x**: Current naming scheme, supports latest devices

### Lesson Learned

**Always match SDK versions between local development and CI environments!**

When device IDs in `manifest.xml` work locally but fail in CI:
1. Check local SDK version: `monkeyc --version`
2. Check CI SDK version: Look at workflow environment variables
3. Verify device exists in both: `ls $SDK_HOME/devices/`
4. Update CI to match local version (or vice versa)

### Best Practices

1. **Document your SDK version** in project README
2. **Use semver patterns** in CI: `^8.0.0` (latest 8.x) vs exact version `8.3.0`
3. **Cache SDK in CI** to speed up builds (already implemented)
4. **Keep local and CI environments in sync**

### Troubleshooting

**Error: "Invalid device id specified"**

1. Check SDK version matches between local and CI
2. Verify devices are installed:
   ```bash
   # Linux/CI
   ls ~/.Garmin/ConnectIQ/Devices/
   
   # macOS
   ls ~/Library/Application\ Support/Garmin/ConnectIQ/Devices/
   ```
3. If devices missing, run device install:
   ```bash
   connect-iq-sdk-manager device install fr265
   connect-iq-sdk-manager device install fenix7
   connect-iq-sdk-manager device install epix2
   connect-iq-sdk-manager device install venu2
   ```

**Devices directory not found**

The CLI SDK Manager stores devices separately from the SDK:
- **Linux**: `~/.Garmin/ConnectIQ/Devices/`
- **macOS**: `~/Library/Application Support/Garmin/ConnectIQ/Devices/`
- **NOT**: `$SDK_HOME/devices/` (SDK directory doesn't contain devices)

### References

- [Connect IQ SDK Releases](https://developer.garmin.com/connect-iq/sdk/)
- [Compatible Devices](https://developer.garmin.com/connect-iq/compatible-devices/)
- [Device API Levels Discussion](https://forums.garmin.com/developer/connect-iq/f/discussion/354168/device-api-levels)
- [CLI SDK Manager (lindell/connect-iq-sdk-manager-cli)](https://github.com/lindell/connect-iq-sdk-manager-cli)
