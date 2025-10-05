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

### The Fix

Updated `.github/workflows/build-and-test.yml` to use SDK 8.x:

```yaml
env:
  # Changed from ^7.0.0 to ^8.0.0
  CONNECTIQ_SDK_VERSION: "^8.0.0"
```

This ensures CI uses the same SDK version as local development.

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

### References

- [Connect IQ SDK Releases](https://developer.garmin.com/connect-iq/sdk/)
- [Compatible Devices](https://developer.garmin.com/connect-iq/compatible-devices/)
- [Device API Levels Discussion](https://forums.garmin.com/developer/connect-iq/f/discussion/354168/device-api-levels)
