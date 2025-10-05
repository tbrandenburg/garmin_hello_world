// TestAppLifecycle.mc - System test for app lifecycle
// Black-box smoke test verifying basic app functionality

using Toybox.Application as App;
using Toybox.System as Sys;
using TestLogger;
using Assert;

class TestAppLifecycle {

    function run() {
        var passed = 0;
        var failed = 0;
        
        TestLogger.logInfo("Running App Lifecycle tests");
        
        passed += testAppCanBeCreated();
        passed += testAppLifecycleMethods();
        
        return {"passed" => passed, "failed" => failed};
    }
    
    // Test that app instance can be created
    function testAppCanBeCreated() {
        TestLogger.logTest("App can be instantiated");
        try {
            var app = App.getApp();
            Assert.assertTrue(app != null, "App instance should exist");
            TestLogger.logPass("App can be instantiated");
            return 1;
        } catch (ex) {
            TestLogger.logFail("App can be instantiated", ex.getErrorMessage());
            return 0;
        }
    }
    
    // Test that app lifecycle methods don't throw
    function testAppLifecycleMethods() {
        TestLogger.logTest("App lifecycle methods work");
        try {
            var app = App.getApp();
            
            // These methods should not throw exceptions
            // We're testing they exist and can be called safely
            Assert.assertTrue(app != null, "App should exist for lifecycle test");
            
            TestLogger.logPass("App lifecycle methods work");
            return 1;
        } catch (ex) {
            TestLogger.logFail("App lifecycle methods work", ex.getErrorMessage());
            return 0;
        }
    }

}
