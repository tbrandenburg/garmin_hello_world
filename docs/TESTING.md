# Testing Guide

This document explains how to run tests and write new test cases for the Garmin Hello World project.

## Running Tests Locally

### Quick Start

```bash
# Run tests with default device (fr265)
make test

# Run for specific device
DEVICE=fenix7 make test

# Run for all devices
make test-all
```

**Simulator Management** (macOS):

The test system automatically manages the Connect IQ Simulator:
- **Auto-restart**: **Always restarts the simulator** before tests for reliability (prevents hangs)
- **Clean state**: Each test run starts with a fresh simulator instance
- **No manual steps**: Just run `make test` - simulator management is automatic
- **Manual control**: 
  - `./scripts/ensure_simulator.sh` - Restart simulator (default)
  - `./scripts/ensure_simulator.sh --no-restart` - Only start if not running (faster but may hang)
  - `./scripts/ensure_simulator.sh --restart` - Force restart (same as default)

**Why auto-restart?** The simulator can get stuck after the first test run. Restarting ensures clean state and prevents test hangs.

### Test Output

Tests produce standardized output markers:
- `[TEST]` - Test starting
- `[PASS]` - Test passed
- `[FAIL]` - Test failed with reason
- `[SKIP]` - Test skipped
- `[SUMMARY]` - Overall results summary
- `[INFO]` - Informational messages

Example output:
```
[INFO] Running MathUtil tests
[TEST] MathUtil.clamp - value below range
[PASS] MathUtil.clamp - value below range
[TEST] MathUtil.clamp - value within range
[PASS] MathUtil.clamp - value within range
...
[SUMMARY] Total: 29, Passed: 29, Failed: 0, Skipped: 0
```

### Test Logs

Test execution logs are saved to `logs/test_<device>_<timestamp>.log` for debugging and CI artifact archival.

## Test Structure

The project now leans on Garmin's Run No Evil (`Toybox.Test`) harness with a thin compatibility layer for our existing asserts:

```
tests/
├── common/           # Shared test infrastructure
│   └── Assert.mc     # Assertion helpers (throw exceptions that Run No Evil catches)
├── unit/             # Unit tests for pure logic
│   ├── TestMathUtil.mc
│   └── TestStringUtil.mc
├── system/           # System/integration tests
│   ├── TestAppLifecycle.mc
│   └── TestUIRendering.mc
└── TestApp.mc        # Registers a `Test.TestSuite` and executes it on startup
```

## Writing Unit Tests

Unit tests verify isolated, pure functions. Place them in `tests/unit/`.

### Template

```monkeyc
using Toybox.Test as Test;
using MyModule;
using Assert;

class MyModuleTestCase extends Test.TestCase {

    function initialize() {
        Test.TestCase.initialize(self, "MyModule");
    }

    function testMyFunction() {
        Assert.assertEquals(30, MyModule.myFunction(10, 20), "Should add numbers");
    }

    function testAnotherFunction() {
        Assert.assertTrue(MyModule.anotherFunction(null) != null, "Handles null input");
    }
}
```

### Assertion Methods

- `Assert.assertTrue(condition, message)` - Verify condition is true
- `Assert.assertEquals(expected, actual, message)` - Verify exact equality
- `Assert.assertApprox(expected, actual, tolerance, message)` - Verify approximate equality (floats)
- `Assert.fail(message)` - Explicit test failure

### Best Practices

1. **One behavior per method** - Keep each `test...` function focused
2. **Test edge cases** - Include boundary values, nulls, negatives
3. **Use descriptive names** - `testClampBelowMin()` not `testClamp1()`
4. **Register new cases** - Add them to `HelloWorldTestSuite` in `tests/TestApp.mc`
5. **Let exceptions bubble** - Throwing from a test automatically marks it as failed

## Writing System Tests

System tests verify end-to-end behavior. Place them in `tests/system/`.

### Guidelines

- Keep tests **black-box** - avoid internal coupling
- Use **smoke tests** - verify basic functionality works
- Be **device-agnostic** - don't rely on specific screen sizes
- **Minimize UI interaction** - simulator testing is limited

### Example

```monkeyc
using Toybox.WatchUi as Ui;
using Assert;
using Toybox.Test as Test;

class MyFeatureSystemCase extends Test.TestCase {

    function initialize() {
        Test.TestCase.initialize(self, "MyFeatureSystem");
    }

    function testFeatureAvailable() {
        var feature = new MyFeature();
        Assert.assertTrue(feature != null, "Feature should exist");
        Assert.assertTrue(feature instanceof Ui.View, "Feature renders via Ui.View");
    }
}
```

## Registering Tests

After creating a test case, register it with the suite in `tests/TestApp.mc`:

```monkeyc
class HelloWorldTestSuite extends Test.TestSuite {

    function initialize() {
        Test.TestSuite.initialize(self, "GarminHelloWorld");
        addTest(new MathUtilTestCase());
        addTest(new StringUtilTestCase());
        addTest(new MyFeatureSystemCase()); // Register new case here
    }
}
```

## Troubleshooting

### Tests Don't Run

**Problem:** `make test` fails immediately

**Solutions:**
- Ensure Connect IQ SDK is installed: `make validate`
- Check `SDK_HOME` environment variable is set
- Verify developer key exists: `ls -la .keys/developer_key.der`
- Try building test app manually: `monkeyc -f monkey.jungle.test -d fr265 -o bin/test.prg -y .keys/developer_key.der`

### Tests Fail to Build

**Problem:** Compilation errors in test code

**Solutions:**
- Check Monkey C syntax - especially dictionary literals use `=>`
- Ensure all `using` statements are present
- Verify test class names match file names
- Check that utility modules compile: `make build`

### Tests Hang or Don't Exit

**Problem:** Simulator doesn't close after tests

**Solutions:**
- Restart the simulator: `./scripts/ensure_simulator.sh --restart`
- Check TestApp timer is configured correctly
- Ensure `Sys.exit()` is called after tests complete
- Verify no infinite loops in test logic
- Check simulator logs for exceptions
- Try manually starting simulator before running tests

### No Test Output

**Problem:** Tests run but no structured output appears in the simulator

**Solutions:**
- Confirm the test app was launched with the `--unit-test` flag (or via the Unit Tests panel)
- Ensure your case extends `Test.TestCase` and throws on failure
- Verify the case is added to `HelloWorldTestSuite`
- Run the test app directly to inspect logs: `monkeydo bin/test_fr265.prg fr265`

## Coverage

Connect IQ doesn't have native code coverage tools. We track coverage manually:

### Current Coverage

- **MathUtil**: ~100% (14 tests covering all functions and edge cases)
- **StringUtil**: ~100% (15 tests covering all functions and edge cases)
- **System Tests**: 4 smoke tests

### Coverage Goals

- **Target**: 80%+ coverage of non-UI code
- **Priority**: Utility modules and business logic
- **Approach**: Focus on black-box testing, avoid brittle UI tests

### Improving Coverage

1. Extract logic into utility modules (like `source/util/`)
2. Write unit tests for new utility functions
3. Add edge case tests for existing code
4. Keep tests simple and maintainable

## CI/CD Integration

Tests run automatically on GitHub Actions for every push and pull request.

### Workflow

1. Code pushed to GitHub
2. CI builds app for all devices
3. CI runs `make test`
4. Test logs uploaded as artifacts
5. Build fails if any tests fail

### Viewing CI Results

- Check Actions tab on GitHub
- Download test logs from artifacts
- Review test summary in workflow output

## Additional Resources

- See [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md) for technical details
- See [../WARP.md](../WARP.md) for Connect IQ development best practices
- See [../README.md](../README.md) for quick start guide
