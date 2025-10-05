// Assert.mc - Simple assertion helpers for testing
// Each assertion throws an exception when the condition fails

using Toybox.Lang as Lang;

module Assert {

    class AssertionError extends Lang.Exception {
        hidden var errorMessage;
        
        function initialize(message) {
            Exception.initialize();
            errorMessage = message;
        }
        
        function getErrorMessage() {
            return errorMessage;
        }
    }

    // Assert that a condition is true
    function assertTrue(condition, message) {
        if (!condition) {
            throw new AssertionError("Assertion failed: " + message);
        }
    }
    
    // Assert that two values are equal
    function assertEquals(expected, actual, message) {
        if (expected != actual) {
            throw new AssertionError(
                "Assertion failed: " + message + 
                " (expected: " + expected + ", actual: " + actual + ")"
            );
        }
    }
    
    // Assert that two floating point values are approximately equal
    function assertApprox(expected, actual, tolerance, message) {
        var diff = expected - actual;
        if (diff < 0) {
            diff = -diff;
        }
        
        if (diff > tolerance) {
            throw new AssertionError(
                "Assertion failed: " + message + 
                " (expected: " + expected + ", actual: " + actual + 
                ", tolerance: " + tolerance + ")"
            );
        }
    }
    
    // Explicit test failure
    function fail(message) {
        throw new AssertionError("Test failed: " + message);
    }

}
