// TestApp.mc - Test application entry point
// Runs test harness and exits when complete

using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Timer;

class TestApp extends App.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
        Sys.println("TestApp starting...");
    }

    function onStop(state) {
        Sys.println("TestApp stopping...");
    }

    function getInitialView() {
        // Schedule test execution shortly after app starts
        var timer = new Timer.Timer();
        var callback = new Lang.Method(self, :runTests);
        timer.start(callback, 100, false);
        
        // Return a minimal view with delegate
        return [ new TestView(), new TestDelegate() ];
    }
    
    function runTests() as Void {
        Sys.println("");
        Sys.println("========================================");
        Sys.println("Garmin Hello World - Test Harness");
        Sys.println("========================================");
        Sys.println("");
        
        var runner = new TestRunner();
        var results = runner.runAll();
        
        Sys.println("");
        
        // Exit with appropriate status
        // Note: Connect IQ doesn't have exit codes, but we can at least exit cleanly
        if (results["failed"] == 0) {
            Sys.println("[SUCCESS] All tests passed!");
        } else {
            Sys.println("[FAILURE] " + results["failed"] + " test(s) failed");
        }
        
        Sys.println("");
        Sys.println("Exiting test app...");
        
        // Give logs time to flush before exiting
        var exitTimer = new Timer.Timer();
        var callback = new Lang.Method(self, :exitApp);
        exitTimer.start(callback, 500, false);
    }
    
    function exitApp() as Void {
        Sys.exit();
    }

}

// Minimal view for test app
class TestView extends Ui.View {

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2,
            Graphics.FONT_SMALL,
            "Running Tests...",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

}

// Test app delegate
class TestDelegate extends Ui.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }
    
    function onBack() {
        Sys.println("Back pressed - exiting tests");
        Sys.exit();
        return true;
    }

}

function getApp() {
    return App.getApp();
}
