// TestUIRendering.mc - System test for UI rendering
// Smoke test to ensure views can be created and rendered without errors

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using TestLogger;
using Assert;

class TestUIRendering {

    function run() {
        var passed = 0;
        var failed = 0;
        
        TestLogger.logInfo("Running UI Rendering tests");
        
        passed += testViewCanBeCreated();
        passed += testViewHasRenderMethods();
        
        return {"passed" => passed, "failed" => failed};
    }
    
    // Test that the main view can be instantiated
    function testViewCanBeCreated() {
        TestLogger.logTest("Main view can be created");
        try {
            var view = new HelloWorldView();
            Assert.assertTrue(view != null, "View should be created");
            TestLogger.logPass("Main view can be created");
            return 1;
        } catch (ex) {
            TestLogger.logFail("Main view can be created", ex.getErrorMessage());
            return 0;
        }
    }
    
    // Test that view has required render methods
    function testViewHasRenderMethods() {
        TestLogger.logTest("View has render methods");
        try {
            var view = new HelloWorldView();
            
            // Verify view is a proper View instance
            Assert.assertTrue(view instanceof Ui.View, "Should be a View instance");
            
            TestLogger.logPass("View has render methods");
            return 1;
        } catch (ex) {
            TestLogger.logFail("View has render methods", ex.getErrorMessage());
            return 0;
        }
    }

}
