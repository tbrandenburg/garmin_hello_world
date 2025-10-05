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
- **Auto-start**: If the simulator isn't running, it will be started automatically
- **Detection**: Checks if the simulator is already running before starting
- **Manual control**: Use `./scripts/ensure_simulator.sh` to check status
- **Force restart**: Use `./scripts/ensure_simulator.sh --restart` to restart the simulator

No manual simulator management is needed - just run `make test`!

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

The project uses a custom test framework designed for Connect IQ:

```
tests/
├── common/           # Shared test infrastructure
│   ├── Assert.mc     # Assertion helpers
│   └── TestLogger.mc # Logging utilities
├── unit/             # Unit tests for pure logic
│   ├── TestMathUtil.mc
│   └── TestStringUtil.mc
├── system/           # System/integration tests
│   ├── TestAppLifecycle.mc
│   └── TestUIRendering.mc
├── TestRunner.mc     # Test orchestrator
└── TestApp.mc        # Test app entry point
```

## Writing Unit Tests

Unit tests verify isolated, pure functions. Place them in `tests/unit/`.

### Template

```monkeyc
using MyModule;
using Assert;
using TestLogger;

class TestMyModule {
    
    function run() {
        var passed = 0;
        var failed = 0;
        
        TestLogger.logInfo("Running MyModule tests");
        
        passed += testMyFunction();
        passed += testAnotherFunction();
        
        return {"passed" => passed, "failed" => failed};
    }
    
    function testMyFunction() {
        TestLogger.logTest("MyModule.myFunction - basic case");
        try {
            var result = MyModule.myFunction(10, 20);
            Assert.assertEquals(30, result, "Should add numbers");
            TestLogger.logPass("MyModule.myFunction - basic case");
            return 1;
        } catch (ex) {
            TestLogger.logFail("MyModule.myFunction - basic case", 
                               ex.getErrorMessage());
            return 0;
        }
    }
    
    function testAnotherFunction() {
        TestLogger.logTest("MyModule.anotherFunction - edge case");
        try {
            var result = MyModule.anotherFunction(null);
            Assert.assertTrue(result != null, "Should handle null input");
            TestLogger.logPass("MyModule.anotherFunction - edge case");
            return 1;
        } catch (ex) {
            TestLogger.logFail("MyModule.anotherFunction - edge case", 
                               ex.getErrorMessage());
            return 0;
        }
    }
}
```

### Assertion Methods

- `Assert.assertTrue(condition, message)` - Verify condition is true
- `Assert.assertEquals(expected, actual, message)` - Verify exact equality
- `Assert.assertApprox(expected, actual, tolerance, message)` - Verify approximate equality (floats)
- `Assert.fail(message)` - Explicit test failure

### Best Practices

1. **One assertion per test** - Keep tests focused
2. **Test edge cases** - Include boundary values, nulls, negatives
3. **Use descriptive names** - `testClampBelowMin()` not `testClamp1()`
4. **Return 1 for pass, 0 for fail** - TestRunner counts results
5. **Catch and log exceptions** - Always wrap in try/catch

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
using TestLogger;

class TestMyFeature {
    
    function run() {
        var passed = 0;
        var failed = 0;
        
        passed += testFeatureAvailable();
        
        return {"passed" => passed, "failed" => failed};
    }
    
    function testFeatureAvailable() {
        TestLogger.logTest("Feature is accessible");
        try {
            // Test that feature can be instantiated
            var feature = new MyFeature();
            Assert.assertTrue(feature != null, "Feature should exist");
            TestLogger.logPass("Feature is accessible");
            return 1;
        } catch (ex) {
            TestLogger.logFail("Feature is accessible", ex.getErrorMessage());
            return 0;
        }
    }
}
```

## Registering Tests

After creating a test class, register it in `tests/TestRunner.mc`:

```monkeyc
var testSuites = [
    // Unit tests
    {"name" => "TestMathUtil", "instance" => new TestMathUtil()},
    {"name" => "TestStringUtil", "instance" => new TestStringUtil()},
    {"name" => "TestMyModule", "instance" => new TestMyModule()},  // Add here
    // System tests
    {"name" => "TestAppLifecycle", "instance" => new TestAppLifecycle()},
    ...
];
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

**Problem:** Tests run but no `[TEST]` markers appear

**Solutions:**
- Verify TestLogger is imported: `using TestLogger;`
- Check log file location: `logs/test_<device>_<timestamp>.log`
- Ensure TestRunner is calling `run()` on each suite
- Try running test app directly: `monkeydo bin/test_fr265.prg fr265`

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
