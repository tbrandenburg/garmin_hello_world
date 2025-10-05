# CI Setup Guide

Complete guide for setting up GitHub Actions CI for Garmin Connect IQ projects.

## Quick Start

### Required GitHub Secrets

Set these in your repository settings (`Settings > Secrets and variables > Actions`):

1. **`GARMIN_USERNAME`** - Your Garmin Connect email
2. **`GARMIN_PASSWORD`** - Your Garmin Connect password  
3. **`MONKEYC_KEY_B64`** - Base64-encoded developer key

### Generate Developer Key

```bash
# Generate key pair
openssl genrsa -out .keys/developer_key.pem 4096
openssl pkcs8 -topk8 -inform PEM -outform DER \
  -in .keys/developer_key.pem \
  -out .keys/developer_key.der \
  -nocrypt

# Encode for GitHub Secret
base64 -i .keys/developer_key.der | pbcopy  # macOS
base64 -w 0 .keys/developer_key.der         # Linux
```

Paste the output into GitHub secret `MONKEYC_KEY_B64`.

## How It Works

### CI Workflow Overview

The GitHub Actions workflow (`.github/workflows/build-and-test.yml`) performs these steps:

1. **Checkout code**
2. **Cache SDK** - Speeds up subsequent runs
3. **Setup developer key** - Decode from GitHub secret
4. **Install Connect IQ SDK 8.x**
   - Uses CLI SDK Manager (no GUI needed)
   - Downloads SDK binaries
   - **Downloads device files separately** (fr265, fenix7, epix2, venu2)
5. **Validate environment** - Verify SDK and devices are available
6. **Build for all devices** - Parallel builds (-j4)
7. **Upload artifacts** - Save .prg files for 90 days

### SDK Version Strategy

The workflow uses SDK 8.x to match local development:

```yaml
env:
  CONNECTIQ_SDK_VERSION: "^8.0.0"  # Latest 8.x
```

**Why 8.x?**
- Device IDs in manifest.xml (fr265, fenix7, epix2, venu2) only exist in SDK 8.x
- SDK 7.x uses different device naming conventions
- Local development uses SDK 8.3.0

## Critical: Devices Are Downloaded Separately

**Important Discovery:** The Connect IQ CLI SDK Manager downloads SDKs and devices as **separate operations**.

### Problem We Solved

Even with SDK 8.3.0 installed, builds failed:
```
ERROR: Invalid device id specified: 'fenix7'.
ls: cannot access '/home/runner/connectiq-sdk/devices': No such file or directory
```

**Why?** The devices directory was empty because devices weren't downloaded.

### Solution

The setup scripts now explicitly download each device:

```bash
/tmp/connect-iq-sdk-manager device download \
  --device fr265 --device fenix7 --device epix2 --device venu2
```

### Device Storage Locations

Devices are stored separately from the SDK:

| Platform | Location |
|----------|----------|
| Linux/CI | `~/.Garmin/ConnectIQ/Devices/` |
| macOS | `~/Library/Application Support/Garmin/ConnectIQ/Devices/` |
| ❌ NOT | `$SDK_HOME/devices/` |

## Security Considerations

### Credential Scoping

Garmin credentials are only accessible during the SDK setup step:

```yaml
- name: Setup Connect IQ SDK
  env:
    GARMIN_USERNAME: ${{ secrets.GARMIN_USERNAME }}
    GARMIN_PASSWORD: ${{ secrets.GARMIN_PASSWORD }}
  run: ./scripts/setup_sdk.sh
```

They are **not** available to other workflow steps.

### Developer Key Security

- ✅ Stored as base64-encoded GitHub secret
- ✅ Decoded only in CI environment
- ✅ Never committed to repository
- ✅ `.keys/` directory is in `.gitignore`

### Key Rotation

To rotate your developer key:

1. Generate new key pair (see above)
2. Update `MONKEYC_KEY_B64` secret in GitHub
3. Next CI run will use new key automatically

## Troubleshooting

### Error: "Invalid device id specified"

**Cause:** Devices not installed or SDK version mismatch

**Fix:**
1. Verify SDK version is 8.x in workflow
2. Check setup script downloads devices
3. Manually verify devices (see below)

### Verify Device Installation

**In CI logs, look for:**
```
[6/6] Verifying device installation...
  Devices directory: /home/runner/.Garmin/ConnectIQ/Devices
  Available devices:
    ✓ fr265
    ✓ fenix7
    ✓ epix2
    ✓ venu2
```

**Locally (macOS):**
```bash
ls ~/Library/Application\ Support/Garmin/ConnectIQ/Devices/
```

**Locally (Linux):**
```bash
ls ~/.Garmin/ConnectIQ/Devices/
```

### Error: "SDK not found"

**Cause:** SDK cache is corrupted or setup failed

**Fix:**
1. Go to GitHub Actions > Click workflow run
2. Click "Re-run jobs" > "Re-run all jobs"
3. If still fails, clear cache:
   - Repository settings > Actions > Caches
   - Delete all caches
   - Re-run workflow

### Error: "Login failed"

**Cause:** Invalid Garmin credentials or expired password

**Fix:**
1. Verify credentials work: https://connect.garmin.com
2. Update secrets in GitHub repository settings
3. Re-run workflow

### Linux-Specific Build Issues

**Problem:** Builds fail with "critical error" on Linux when using parallel builds

**Root Cause:** The Linux monkeyc compiler cannot handle parallel builds (`-j` flag).
The `-g` debug flag was initially thought to be required, but testing proved it was
only needed when using parallel builds.

**Solution:** CI uses sequential builds (no `-j` flag) for reliability on Linux.
This works perfectly without requiring the `-g` flag.

**Discovery:** After switching to sequential builds, we verified that the `-g` flag
is not actually needed on Linux. The compiler works fine without debug symbols when
building sequentially.

### Builds Work Locally But Fail in CI

**Check these differences:**

| Item | Local | CI | Fix |
|------|-------|----|----|
| SDK Version | `monkeyc --version` | Check workflow YAML | Match versions |
| Devices | `ls ~/Library/.../Devices/` | Check CI logs | Ensure devices downloaded |
| Developer Key | `.keys/developer_key.der` | GitHub secret | Verify secret is set |
| Parallel Builds | `make buildall -j4` (macOS) | `make buildall` (Linux) | Use sequential in CI |

## Manual Device Installation

If you need to install devices manually:

```bash
# Install CLI SDK Manager
curl -s https://raw.githubusercontent.com/lindell/connect-iq-sdk-manager-cli/master/install.sh | sh

# Login
connect-iq-sdk-manager login

# Install devices
connect-iq-sdk-manager device download --device fr265
connect-iq-sdk-manager device download --device fenix7
connect-iq-sdk-manager device download --device epix2
connect-iq-sdk-manager device download --device venu2

# Verify
connect-iq-sdk-manager device list
```

## Performance Optimization

### SDK Caching

The workflow caches the SDK to speed up builds:

```yaml
- name: Cache Connect IQ SDK
  uses: actions/cache@v4
  with:
    path: |
      ~/connectiq-sdk
      ~/.Garmin/ConnectIQ/Sdks
    key: connectiq-sdk-${{ runner.os }}-${{ env.CONNECTIQ_SDK_VERSION }}-v3
```

**Benefits:**
- First run: ~2-3 minutes for SDK download
- Cached runs: ~5-10 seconds (cache restore)
- Cache is SDK version-specific

### Parallel Builds

**⚠️ Important:** Parallel builds work on macOS but **fail on Linux CI** with
"critical errors" from the compiler. The workflow uses sequential builds for
reliability.

```bash
# CI uses sequential builds (reliable)
make buildall

# Local macOS can use parallel (faster)
make buildall -j4
```

**Build times:**
- Sequential: ~20-30 seconds for 4 devices (used in CI)
- Parallel (-j4): ~8-10 seconds (macOS only, not used in CI)

## Best Practices

1. **Keep SDK versions in sync**
   - Local and CI should use same major version (8.x)
   - Update workflow when upgrading locally

2. **Test CI changes in PR**
   - Workflow runs on pull requests
   - Verify before merging to main

3. **Monitor cache size**
   - SDK + devices ≈ 200-300MB
   - GitHub free tier: 10GB cache limit

4. **Rotate credentials periodically**
   - Update Garmin password → Update GitHub secret
   - Rotate developer key annually

5. **Review failed builds promptly**
   - Check CI logs for specific errors
   - Most issues are credential or device-related

## Files Reference

| File | Purpose |
|------|---------|
| `.github/workflows/build-and-test.yml` | Main CI workflow |
| `scripts/setup_sdk.sh` | Linux SDK setup script |
| `scripts/setup_sdk_macos.sh` | macOS SDK setup script |
| `.gitignore` | Excludes `.keys/`, `bin/`, etc. |

## Resources

- [Connect IQ SDK Releases](https://developer.garmin.com/connect-iq/sdk/)
- [Compatible Devices](https://developer.garmin.com/connect-iq/compatible-devices/)
- [CLI SDK Manager](https://github.com/lindell/connect-iq-sdk-manager-cli)
- [GitHub Actions Cache](https://docs.github.com/en/actions/using-workflows/caching-dependencies-to-speed-up-workflows)
