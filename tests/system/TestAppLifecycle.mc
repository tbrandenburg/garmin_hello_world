using Toybox.Test as Test;
using Toybox.Application as App;
using Assert;

class AppLifecycleTestCase extends Test.TestCase {

    function initialize() {
        Test.TestCase.initialize(self, "AppLifecycle");
    }

    function testAppCanBeCreated() {
        var app = App.getApp();
        Assert.assertTrue(app != null, "Application instance should exist during tests");
    }

    function testLifecycleHooksAreReachable() {
        var app = App.getApp();
        Assert.assertTrue(app != null, "App instance is required for lifecycle assertions");
        var viewBundle = app.getInitialView();
        Assert.assertTrue(viewBundle != null, "getInitialView returns view/delegate pair");
        Assert.assertTrue(viewBundle.size() == 2, "Initial view bundle provides view + delegate");
    }
}
