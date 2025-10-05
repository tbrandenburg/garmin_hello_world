// TestLogger.mc - Standardized test logging with parseable markers
// Used by test scripts to determine pass/fail status

using Toybox.System as Sys;

module TestLogger {

    // Log the start of a test
    function logTest(testName) {
        Sys.println("[TEST] " + testName);
    }
    
    // Log a passing test
    function logPass(testName) {
        Sys.println("[PASS] " + testName);
    }
    
    // Log a failing test with reason
    function logFail(testName, reason) {
        Sys.println("[FAIL] " + testName + ": " + reason);
    }
    
    // Log a skipped test with reason
    function logSkip(testName, reason) {
        Sys.println("[SKIP] " + testName + ": " + reason);
    }
    
    // Log test summary
    function logSummary(total, passed, failed, skipped) {
        Sys.println("[SUMMARY] Total: " + total + 
                    ", Passed: " + passed + 
                    ", Failed: " + failed + 
                    ", Skipped: " + skipped);
    }
    
    // Generic info logging
    function logInfo(message) {
        Sys.println("[INFO] " + message);
    }

}
