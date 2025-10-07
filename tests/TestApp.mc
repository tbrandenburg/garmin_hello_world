// TestApp.mc - Connect IQ Unit Testing with proper (:test) annotations
// Tests are executed automatically by the Connect IQ framework using monkeydo /t

using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Graphics;
using Toybox.Test as Test;
using MathUtil;
using StringUtil;

// Simple test application - the real tests are the (:test) functions below
class TestApp extends App.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
        // This is just the regular app - tests run separately via monkeydo /t
    }
    
    function getInitialView() {
        return [ new TestView(), new TestDelegate() ];
    }

    function onStop(state) {
    }
}

// Required global function for Connect IQ apps
function getApp() {
    return App.getApp();
}

// Simple test view
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
            "Connect IQ Unit Tests",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}

class TestDelegate extends Ui.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onBack() {
        Sys.exit();
        return true;
    }
}

// Tests are defined in separate files in tests/unit/ and tests/system/ directories
// with proper (:test) annotations
