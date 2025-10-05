// TestStringUtil.mc - Unit tests for StringUtil module
// Tests all edge cases and logical paths

using StringUtil;
using Assert;
using TestLogger;

class TestStringUtil {

    function run() {
        var passed = 0;
        var failed = 0;
        
        TestLogger.logInfo("Running StringUtil tests");
        
        // Test formatTime function
        passed += testFormatTimeSeconds();
        passed += testFormatTimeMinutes();
        passed += testFormatTimeHours();
        passed += testFormatTimeLarge();
        passed += testFormatTimeZero();
        passed += testFormatTimeNegative();
        
        // Test capitalize function
        passed += testCapitalizeEmpty();
        passed += testCapitalizeAlreadyCap();
        passed += testCapitalizeLowercase();
        passed += testCapitalizeNonAlpha();
        
        // Test truncate function
        passed += testTruncateShorter();
        passed += testTruncateEqual();
        passed += testTruncateLongerWithEllipsis();
        passed += testTruncateLongerWithoutEllipsis();
        passed += testTruncateSmallMax();
        
        return {"passed" => passed, "failed" => failed};
    }
    
    // Test formatTime with seconds only
    function testFormatTimeSeconds() {
        TestLogger.logTest("StringUtil.formatTime - seconds");
        try {
            var result = StringUtil.formatTime(45);
            Assert.assertEquals("00:45", result, "45 seconds should be 00:45");
            TestLogger.logPass("StringUtil.formatTime - seconds");
            return 1;
        } catch (ex) {
            TestLogger.logFail("StringUtil.formatTime - seconds", ex.getErrorMessage());
            return 0;
        }
    }
    
    // Test formatTime with minutes
    function testFormatTimeMinutes() {
        TestLogger.logTest("StringUtil.formatTime - minutes");
        try {
            var result = StringUtil.formatTime(125);
            Assert.assertEquals("02:05", result, "125 seconds should be 02:05");
            TestLogger.logPass("StringUtil.formatTime - minutes");
            return 1;
        } catch (ex) {
            TestLogger.logFail("StringUtil.formatTime - minutes", ex.getErrorMessage());
            return 0;
        }
    }
    
    // Test formatTime with hours
    function testFormatTimeHours() {
        TestLogger.logTest("StringUtil.formatTime - hours");
        try {
            var result = StringUtil.formatTime(3665);
            Assert.assertEquals("1:01:05", result, "3665 seconds should be 1:01:05");
            TestLogger.logPass("StringUtil.formatTime - hours");
            return 1;
        } catch (ex) {
            TestLogger.logFail("StringUtil.formatTime - hours", ex.getErrorMessage());
            return 0;
        }
    }
    
    // Test formatTime with large value
    function testFormatTimeLarge() {
        TestLogger.logTest("StringUtil.formatTime - large value");
        try {
            var result = StringUtil.formatTime(36000);
            Assert.assertEquals("10:00:00", result, "36000 seconds should be 10:00:00");
            TestLogger.logPass("StringUtil.formatTime - large value");
            return 1;
        } catch (ex) {
            TestLogger.logFail("StringUtil.formatTime - large value", ex.getErrorMessage());
            return 0;
        }
    }
    
    // Test formatTime with zero
    function testFormatTimeZero() {
        TestLogger.logTest("StringUtil.formatTime - zero");
        try {
            var result = StringUtil.formatTime(0);
            Assert.assertEquals("00:00", result, "0 seconds should be 00:00");
            TestLogger.logPass("StringUtil.formatTime - zero");
            return 1;
        } catch (ex) {
            TestLogger.logFail("StringUtil.formatTime - zero", ex.getErrorMessage());
            return 0;
        }
    }
    
    // Test formatTime with negative (should return 00:00)
    function testFormatTimeNegative() {
        TestLogger.logTest("StringUtil.formatTime - negative");
        try {
            var result = StringUtil.formatTime(-10);
            Assert.assertEquals("00:00", result, "Negative should return 00:00");
            TestLogger.logPass("StringUtil.formatTime - negative");
            return 1;
        } catch (ex) {
            TestLogger.logFail("StringUtil.formatTime - negative", ex.getErrorMessage());
            return 0;
        }
    }
    
    // Test capitalize with empty string
    function testCapitalizeEmpty() {
        TestLogger.logTest("StringUtil.capitalize - empty");
        try {
            var result = StringUtil.capitalize("");
            Assert.assertEquals("", result, "Empty string should return empty");
            TestLogger.logPass("StringUtil.capitalize - empty");
            return 1;
        } catch (ex) {
            TestLogger.logFail("StringUtil.capitalize - empty", ex.getErrorMessage());
            return 0;
        }
    }
    
    // Test capitalize with already capitalized
    function testCapitalizeAlreadyCap() {
        TestLogger.logTest("StringUtil.capitalize - already capitalized");
        try {
            var result = StringUtil.capitalize("Hello");
            Assert.assertEquals("Hello", result, "Should remain capitalized");
            TestLogger.logPass("StringUtil.capitalize - already capitalized");
            return 1;
        } catch (ex) {
            TestLogger.logFail("StringUtil.capitalize - already capitalized", ex.getErrorMessage());
            return 0;
        }
    }
    
    // Test capitalize with lowercase
    function testCapitalizeLowercase() {
        TestLogger.logTest("StringUtil.capitalize - lowercase");
        try {
            var result = StringUtil.capitalize("hello");
            Assert.assertEquals("Hello", result, "Should capitalize first letter");
            TestLogger.logPass("StringUtil.capitalize - lowercase");
            return 1;
        } catch (ex) {
            TestLogger.logFail("StringUtil.capitalize - lowercase", ex.getErrorMessage());
            return 0;
        }
    }
    
    // Test capitalize with non-alphabetic first character
    function testCapitalizeNonAlpha() {
        TestLogger.logTest("StringUtil.capitalize - non-alphabetic");
        try {
            var result = StringUtil.capitalize("123abc");
            Assert.assertEquals("123abc", result, "Non-alpha first char should remain");
            TestLogger.logPass("StringUtil.capitalize - non-alphabetic");
            return 1;
        } catch (ex) {
            TestLogger.logFail("StringUtil.capitalize - non-alphabetic", ex.getErrorMessage());
            return 0;
        }
    }
    
    // Test truncate with string shorter than max
    function testTruncateShorter() {
        TestLogger.logTest("StringUtil.truncate - shorter");
        try {
            var result = StringUtil.truncate("Hello", 10, true);
            Assert.assertEquals("Hello", result, "Short string should not truncate");
            TestLogger.logPass("StringUtil.truncate - shorter");
            return 1;
        } catch (ex) {
            TestLogger.logFail("StringUtil.truncate - shorter", ex.getErrorMessage());
            return 0;
        }
    }
    
    // Test truncate with string equal to max
    function testTruncateEqual() {
        TestLogger.logTest("StringUtil.truncate - equal");
        try {
            var result = StringUtil.truncate("Hello", 5, true);
            Assert.assertEquals("Hello", result, "Equal length should not truncate");
            TestLogger.logPass("StringUtil.truncate - equal");
            return 1;
        } catch (ex) {
            TestLogger.logFail("StringUtil.truncate - equal", ex.getErrorMessage());
            return 0;
        }
    }
    
    // Test truncate with ellipsis
    function testTruncateLongerWithEllipsis() {
        TestLogger.logTest("StringUtil.truncate - with ellipsis");
        try {
            var result = StringUtil.truncate("Hello World", 8, true);
            Assert.assertEquals("Hello...", result, "Should truncate and add ellipsis");
            TestLogger.logPass("StringUtil.truncate - with ellipsis");
            return 1;
        } catch (ex) {
            TestLogger.logFail("StringUtil.truncate - with ellipsis", ex.getErrorMessage());
            return 0;
        }
    }
    
    // Test truncate without ellipsis
    function testTruncateLongerWithoutEllipsis() {
        TestLogger.logTest("StringUtil.truncate - without ellipsis");
        try {
            var result = StringUtil.truncate("Hello World", 5, false);
            Assert.assertEquals("Hello", result, "Should truncate without ellipsis");
            TestLogger.logPass("StringUtil.truncate - without ellipsis");
            return 1;
        } catch (ex) {
            TestLogger.logFail("StringUtil.truncate - without ellipsis", ex.getErrorMessage());
            return 0;
        }
    }
    
    // Test truncate with very small max
    function testTruncateSmallMax() {
        TestLogger.logTest("StringUtil.truncate - small max");
        try {
            var result = StringUtil.truncate("Hello", 2, true);
            Assert.assertEquals("He", result, "Very small max should just truncate");
            TestLogger.logPass("StringUtil.truncate - small max");
            return 1;
        } catch (ex) {
            TestLogger.logFail("StringUtil.truncate - small max", ex.getErrorMessage());
            return 0;
        }
    }

}
