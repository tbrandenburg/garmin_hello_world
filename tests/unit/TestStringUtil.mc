// TestStringUtil.mc - Function-based tests for StringUtil module
// Uses Connect IQ's function-based testing with :test annotations

using Toybox.Test as Test;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using StringUtil;

// Test time formatting function
(:test)
function testStringUtilFormatTime(logger as Test.Logger) as Lang.Boolean {
    logger.debug("Testing StringUtil.formatTime() formatting");
    
    // Test negative seconds clamp to zero
    Test.assertEqual("00:00", StringUtil.formatTime(-5));
    
    // Test under a minute with padding
    Test.assertEqual("00:05", StringUtil.formatTime(5));
    
    // Test minute rollover
    Test.assertEqual("01:05", StringUtil.formatTime(65));
    
    // Test hours formatting (no padding for leading hour)
    Test.assertEqual("1:01:01", StringUtil.formatTime(3661));
    
    logger.debug("StringUtil.formatTime() tests completed");
    return true;
}

// Test string capitalization function
(:test)
function testStringUtilCapitalize(logger as Test.Logger) as Lang.Boolean {
    logger.debug("Testing StringUtil.capitalize() capitalization");
    
    // Test empty string stays empty
    Test.assertEqual("", StringUtil.capitalize(""));
    
    // Test single character capitalizes
    Test.assertEqual("A", StringUtil.capitalize("a"));
    
    // Test lowercase prefix capitalizes only first letter
    Test.assertEqual("Hello", StringUtil.capitalize("hello"));
    
    logger.debug("StringUtil.capitalize() tests completed");
    return true;
}

// Test string truncation function
(:test)
function testStringUtilTruncate(logger as Test.Logger) as Lang.Boolean {
    logger.debug("Testing StringUtil.truncate() truncation");
    
    // Test no truncation when under max
    Test.assertEqual("hello", StringUtil.truncate("hello", 10, true));
    
    // Test straight truncation without ellipsis
    Test.assertEqual("hel", StringUtil.truncate("hello", 3, false));
    
    // Test ellipsis counts toward budget
    Test.assertEqual("he...", StringUtil.truncate("hello", 5, true));
    
    // Test short budgets skip ellipsis
    Test.assertEqual("hel", StringUtil.truncate("hello", 3, true));
    
    // Test null inputs map to empty string
    Test.assertEqual("", StringUtil.truncate(null, 5, true));
    
    logger.debug("StringUtil.truncate() tests completed");
    return true;
}
