// TestRunner.mc - Test orchestrator that runs all test suites
// Collects results and prints summary

using Toybox.System as Sys;
using Toybox.Lang as Lang;
using TestLogger;

class TestRunner {

    // Run all test suites and return overall results
    function runAll() {
        TestLogger.logInfo("===================================");
        TestLogger.logInfo("Starting Test Suite Execution");
        TestLogger.logInfo("===================================");
        
        var totalPassed = 0;
        var totalFailed = 0;
        var totalSkipped = 0;
        
        // Register all test suites
        var testSuites = [
            // Unit tests
            {"name" => "TestMathUtil", "instance" => new TestMathUtil()},
            {"name" => "TestStringUtil", "instance" => new TestStringUtil()},
            // System tests
            {"name" => "TestAppLifecycle", "instance" => new TestAppLifecycle()},
            {"name" => "TestUIRendering", "instance" => new TestUIRendering()}
        ];
        
        // Run each test suite
        for (var i = 0; i < testSuites.size(); i++) {
            var suite = testSuites[i];
            TestLogger.logInfo("");
            TestLogger.logInfo("Running suite: " + suite["name"]);
            TestLogger.logInfo("-----------------------------------");
            
            try {
                var result = suite["instance"].run();
                var passed = result["passed"];
                var failed = result["failed"];
                
                totalPassed += passed;
                totalFailed += failed;
                
                TestLogger.logInfo("Suite " + suite["name"] + " complete: " + 
                                   passed + " passed, " + failed + " failed");
            } catch (ex) {
                TestLogger.logFail(suite["name"], "Suite crashed: " + ex.getErrorMessage());
                totalFailed += 1;
            }
        }
        
        // Print final summary
        var totalTests = totalPassed + totalFailed + totalSkipped;
        TestLogger.logInfo("");
        TestLogger.logInfo("===================================");
        TestLogger.logInfo("Test Execution Complete");
        TestLogger.logInfo("===================================");
        TestLogger.logSummary(totalTests, totalPassed, totalFailed, totalSkipped);
        
        return {
            "total" => totalTests,
            "passed" => totalPassed,
            "failed" => totalFailed,
            "skipped" => totalSkipped
        };
    }

}
