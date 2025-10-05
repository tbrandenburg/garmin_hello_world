# Documentation Consistency Report

Generated: 2025-10-05

## Executive Summary

✅ **Overall Status**: Documentation is **mostly consistent** with a few minor updates needed.

The documentation accurately reflects the current project state, with the following findings:

## Findings by Document

### ✅ README.md - GOOD
**Status**: Accurate and up-to-date

**Verified Items**:
- ✓ Quick start instructions match actual setup scripts
- ✓ Build instructions reference correct Makefile targets
- ✓ Supported devices list matches manifest.xml
- ✓ Project structure reflects actual file layout
- ✓ Links to docs are correct

**Minor Issue**:
- ⚠️ References `docs/SDK_SETUP.md` which doesn't exist (replaced by CI_SETUP.md)

**Recommended Fix**:
```markdown
# Change line 46 and 71 from:
- **[docs/SDK_SETUP.md](docs/SDK_SETUP.md)** - Complete SDK setup guide

# To:
- **[docs/CI_SETUP.md](docs/CI_SETUP.md)** - Complete SDK and CI setup guide
```

---

### ⚠️ WARP.md - NEEDS MINOR UPDATE
**Status**: Comprehensive but contains outdated CI information

**Verified Items**:
- ✓ Project configuration accurate
- ✓ SDK version strategy correct (4.2.x minimum, 8.x recommended)
- ✓ Makefile build system documentation complete
- ✓ Quick start instructions work
- ✓ Device IDs correct

**Issues Found**:

1. **Parallel Builds Section (lines 236-253)**
   - ❌ States: "Parallel (-j4): ~8-10 seconds"
   - ✅ Reality: Parallel builds **fail on Linux CI** (discovered recently)
   - Current CI uses sequential builds only

2. **CI/CD Integration Section (lines 275-315)**
   - ❌ Shows example with `make buildall -j$(nproc)`
   - ✅ Reality: CI uses `make buildall` (no -j flag)

**Recommended Fixes**:

```markdown
# Line 236-253: Update Parallel Builds section
### Parallel Builds

Build for all devices simultaneously:

```bash
# Auto-detect CPU cores (works on macOS, may fail on Linux)
make buildall -j

# Specify job count (works on macOS, may fail on Linux)
make buildall -j4

# Sequential (reliable everywhere, including CI)
make buildall
```

**Build times (4 devices):**
- Sequential: ~20-30 seconds (reliable on all platforms)
- Parallel (-j4): ~8-10 seconds (works on macOS, **fails on Linux**)

**CI Note:** GitHub Actions uses sequential builds because parallel builds
cause "critical errors" with the Linux monkeyc compiler.

# Line 306: Update CI workflow example
      # Build all devices (sequential for Linux compatibility)
      - name: Build All
        run: make buildall
```

3. **SDK Version Info**
   - ⚠️ Mentions "4.2.x" but project now uses "8.3.0"
   - Should clarify: "Minimum SDK 4.2.x, recommended 8.x for modern devices"

---

### ✅ docs/BUILD.md - GOOD
**Status**: Accurate legacy documentation

**Verified Items**:
- ✓ Prerequisites section correct
- ✓ Environment variable setup accurate
- ✓ Build commands work
- ✓ Simulator instructions correct
- ✓ Physical device installation steps valid

**Notes**:
- Correctly references the Makefile as the recommended build method
- Legacy `monkeyc` command examples still work (good for reference)

---

### ⚠️ docs/CI_SETUP.md - NEEDS MINOR UPDATE
**Status**: Generally accurate but missing recent discoveries

**Issues Found**:

1. **Parallel Builds Section (line 235-244)**
   - ❌ States: "Parallel (-j4): ~8-10 seconds"
   - ✅ Reality: Doesn't work on Linux CI

**Recommended Fix**:
```markdown
# Line 235-244: Update parallel builds section
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
```

2. **Missing Recent Fix**
   - Document doesn't mention the `-g` flag requirement for Linux
   - Should add note in troubleshooting section

**Recommended Addition**:
```markdown
### Linux-Specific Build Issues

**Problem:** Builds fail with "critical error" on Linux but work on macOS

**Cause:** Linux monkeyc compiler requires debug symbols flag (`-g`)

**Solution:** Our Makefile includes `-g` in `DEBUG_FLAGS` by default:
```makefile
DEBUG_FLAGS ?= $(COMMON_FLAGS) -g  # -g required for Linux builds
```

This is why `BUILD_MODE=release` may fail on Linux (release flags don't include `-g`).
```

---

### ✅ docs/TESTING.md - GOOD
**Status**: Accurate

**Verified Items**:
- ✓ Test structure matches actual implementation
- ✓ Commands work as documented
- ✓ Template examples are correct
- ✓ Simulator management correctly documented

---

### ✅ docs/IMPLEMENTATION_GUIDE.md - GOOD
**Status**: Accurate historical record

**Verified Items**:
- ✓ Completion status matches reality
- ✓ Phase descriptions accurate
- ✓ Code examples correct

---

## Truth vs. Documentation

### Current CI Reality

**What Actually Happens in CI** (from `.github/workflows/build-and-test.yml`):

```yaml
# Line 120: Sequential build
- name: Build All Devices
  run: make buildall  # NO -j flag!
```

**Why Sequential**:
- Parallel builds (`-j4`) cause "critical errors" on Linux
- Works perfectly on macOS
- Trade-off: ~10-20 seconds slower, but reliable

**Build Configuration** (from `config.mk`):

```makefile
# Line 75-76: Debug flags include -g for Linux compatibility
DEBUG_FLAGS ?= $(COMMON_FLAGS) -g  # -g required for Linux builds
```

### Devices Reality

**Actual Device Storage** (verified in CI logs):
- Linux: `~/.Garmin/ConnectIQ/Devices/`
- macOS: `~/Library/Application Support/Garmin/ConnectIQ/Devices/`
- **NOT**: `$SDK_HOME/devices/` (empty directory)

All docs correctly state this.

### SDK Version Reality

**Current Usage**:
- Local: SDK 8.3.0
- CI: SDK ^8.0.0 (latest 8.x)
- Manifest devices require 8.x (fr265, fenix7, epix2, venu2)

WARP.md mentions "4.2.x" as minimum but clarifies 8.x is needed for modern devices. Could be clearer.

---

## Recommended Actions

### Priority 1: Fix Broken Links
1. Update README.md line 46 and 71: `SDK_SETUP.md` → `CI_SETUP.md`

### Priority 2: Update Parallel Build Info
1. Update WARP.md lines 236-253 and 306 (CI example)
2. Update CI_SETUP.md lines 235-244

### Priority 3: Add Linux Build Notes
1. Add section to CI_SETUP.md about `-g` flag requirement

### Priority 4: Clarify SDK Versions
1. Update WARP.md introduction to clearly state:
   - Minimum: 4.2.x
   - Recommended: 8.x
   - Required for modern devices: 8.x

---

## Commands to Apply Fixes

```bash
# 1. Fix README.md
sed -i '' 's/SDK_SETUP\.md/CI_SETUP.md/g' README.md

# 2-4. Manual edits required for WARP.md and CI_SETUP.md
# (use text editor to apply recommended fixes above)
```

---

## Verification Checklist

After applying fixes:

- [ ] All links in README.md work
- [ ] WARP.md accurately describes CI build behavior
- [ ] CI_SETUP.md reflects parallel build limitation
- [ ] No broken cross-references between docs
- [ ] SDK version strategy is clear

---

## Conclusion

The documentation is in excellent shape overall. The main inconsistency is the
recent discovery that parallel builds don't work on Linux CI, which occurred
after the initial documentation was written.

All fixes are minor and straightforward. The documentation accurately reflects
the project structure, commands, and workflows.
