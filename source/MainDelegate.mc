using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

class HelloWorldDelegate extends Ui.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // Handle the back button press to exit the app
    function onBack() {
        Sys.println("Back button pressed - exiting app");
        Sys.exit();
        // No return needed after exit
    }

    // Handle the select/enter button press
    function onSelect() {
        Sys.println("Select button pressed");
        return true;
    }

}
