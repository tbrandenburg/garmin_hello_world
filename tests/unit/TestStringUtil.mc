using Toybox.Test as Test;
using StringUtil;
using Assert;

class StringUtilTestCase extends Test.TestCase {

    function initialize() {
        Test.TestCase.initialize(self, "StringUtil");
    }

    function testFormatTime() {
        Assert.assertEquals("00:00", StringUtil.formatTime(-5), "Negative seconds clamp to zero");
        Assert.assertEquals("00:05", StringUtil.formatTime(5), "Formats under a minute with padding");
        Assert.assertEquals("01:05", StringUtil.formatTime(65), "Formats minute rollover correctly");
        Assert.assertEquals("1:01:01", StringUtil.formatTime(3661), "Hours add third segment without padding leading zero");
    }

    function testCapitalize() {
        Assert.assertEquals("", StringUtil.capitalize(""), "Empty strings stay empty");
        Assert.assertEquals("A", StringUtil.capitalize("a"), "Single character capitalizes");
        Assert.assertEquals("Hello", StringUtil.capitalize("hello"), "Lowercase prefix capitalizes only first letter");
    }

    function testTruncate() {
        Assert.assertEquals("hello", StringUtil.truncate("hello", 10, true), "No truncation when under max");
        Assert.assertEquals("hel", StringUtil.truncate("hello", 3, false), "Straight truncation without ellipsis");
        Assert.assertEquals("he...", StringUtil.truncate("hello", 5, true), "Ellipsis counts toward budget");
        Assert.assertEquals("hel", StringUtil.truncate("hello", 3, true), "Short budgets skip ellipsis");
        Assert.assertEquals("", StringUtil.truncate(null, 5, true), "Null inputs map to empty string");
    }
}
