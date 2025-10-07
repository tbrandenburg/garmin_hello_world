// TestUIRendering.mc - Function-based tests for UI rendering
// Uses Connect IQ's function-based testing with :test annotations

using Toybox.Test as Test;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Lang as Lang;

// Test that the primary view can be instantiated and is properly typed
(:test)
function testViewInstantiation(logger as Test.Logger) as Lang.Boolean {
    logger.debug("Testing HelloWorldView instantiation");
    
    var view = new HelloWorldView();
    Test.assert(view != null);
    Test.assert(view instanceof Ui.View);
    
    logger.debug("HelloWorldView instantiation test completed");
    return true;
}
