// TestAppLifecycle.mc - Function-based tests for application lifecycle
// Uses Connect IQ's function-based testing with :test annotations

using Toybox.Test as Test;
using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Lang as Lang;

// Test that application instance can be created and accessed
(:test)
function testAppCanBeCreated(logger as Test.Logger) as Lang.Boolean {
    logger.debug("Testing application instance creation");
    
    var app = App.getApp();
    Test.assert(app != null);
    
    logger.debug("Application instance creation test completed");
    return true;
}

// Test that lifecycle hooks are reachable and functioning
(:test)
function testLifecycleHooksAreReachable(logger as Test.Logger) as Lang.Boolean {
    logger.debug("Testing application lifecycle hooks");
    
    var app = App.getApp();
    Test.assert(app != null);
    
    var viewBundle = app.getInitialView();
    Test.assert(viewBundle != null);
    Test.assert(viewBundle.size() == 2);
    
    logger.debug("Application lifecycle hooks test completed");
    return true;
}
