using Toybox.Test as Test;
using Toybox.WatchUi as Ui;
using Assert;

class UIRenderingTestCase extends Test.TestCase {

    function initialize() {
        Test.TestCase.initialize(self, "UIRendering");
    }

    function testViewInstantiation() {
        var view = new HelloWorldView();
        Assert.assertTrue(view != null, "Primary view can be constructed");
        Assert.assertTrue(view instanceof Ui.View, "Primary view derives from Ui.View");
    }
}
