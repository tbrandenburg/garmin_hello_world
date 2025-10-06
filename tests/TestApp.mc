using Toybox.Application as App;
using Toybox.Test as Test;
using Toybox.System as Sys;
using Toybox.Timer;
using Toybox.Lang as Lang;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Graphics;

class HelloWorldTestSuite extends Test.TestSuite {

    function initialize() {
        Test.TestSuite.initialize(self, "GarminHelloWorld");
        addTest(new MathUtilTestCase());
        addTest(new StringUtilTestCase());
        addTest(new AppLifecycleTestCase());
        addTest(new UIRenderingTestCase());
    }
}

class TestApp extends App.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
        var timer = new Timer.Timer();
        timer.start(new Lang.Method(self, :runTests), 100, false);
    }

    function runTests() {
        var suite = new HelloWorldTestSuite();
        Test.run(suite);
        Sys.println("Run No Evil test suite completed");
        Sys.exit();
    }

    function getInitialView() {
        return [ new TestView(), new TestDelegate() ];
    }
}

function getApp() {
    return App.getApp();
}

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
            "Run No Evil Tests",
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
