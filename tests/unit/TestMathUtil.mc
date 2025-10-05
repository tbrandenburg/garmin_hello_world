// TestMathUtil.mc - Unit tests for MathUtil module
// Tests all edge cases and logical paths

using MathUtil;
using Assert;
using TestLogger;

class TestMathUtil {

    function run() {
        var passed = 0;
        var failed = 0;
        
        TestLogger.logInfo("Running MathUtil tests");
        
        // Test clamp function
        passed += testClampBelowRange();
        passed += testClampWithinRange();
        passed += testClampAboveRange();
        
        // Test roundTo function
        passed += testRoundToPositive();
        passed += testRoundToNegative();
        passed += testRoundToZero();
        passed += testRoundToMultipleDecimals();
        passed += testRoundToBoundary();
        
        // Test percentage function
        passed += testPercentageZero();
        passed += testPercentageMid();
        passed += testPercentage100();
        passed += testPercentageBelowZero();
        passed += testPercentageAbove100();
        passed += testPercentageZeroTotal();
        
        return {"passed" => passed, "failed" => failed};
    }
    
    // Test clamp with value below min
    function testClampBelowRange() {
        TestLogger.logTest("MathUtil.clamp - value below range");
        try {
            var result = MathUtil.clamp(5, 10, 20);
            Assert.assertEquals(10, result, "Should clamp to min");
            TestLogger.logPass("MathUtil.clamp - value below range");
            return 1;
        } catch (ex) {
            TestLogger.logFail("MathUtil.clamp - value below range", ex.getErrorMessage());
            return 0;
        }
    }
    
    // Test clamp with value within range
    function testClampWithinRange() {
        TestLogger.logTest("MathUtil.clamp - value within range");
        try {
            var result = MathUtil.clamp(15, 10, 20);
            Assert.assertEquals(15, result, "Should return original value");
            TestLogger.logPass("MathUtil.clamp - value within range");
            return 1;
        } catch (ex) {
            TestLogger.logFail("MathUtil.clamp - value within range", ex.getErrorMessage());
            return 0;
        }
    }
    
    // Test clamp with value above max
    function testClampAboveRange() {
        TestLogger.logTest("MathUtil.clamp - value above range");
        try {
            var result = MathUtil.clamp(25, 10, 20);
            Assert.assertEquals(20, result, "Should clamp to max");
            TestLogger.logPass("MathUtil.clamp - value above range");
            return 1;
        } catch (ex) {
            TestLogger.logFail("MathUtil.clamp - value above range", ex.getErrorMessage());
            return 0;
        }
    }
    
    // Test roundTo with positive number
    function testRoundToPositive() {
        TestLogger.logTest("MathUtil.roundTo - positive number");
        try {
            var result = MathUtil.roundTo(3.14159, 2);
            Assert.assertApprox(3.14, result, 0.01, "Should round to 2 decimals");
            TestLogger.logPass("MathUtil.roundTo - positive number");
            return 1;
        } catch (ex) {
            TestLogger.logFail("MathUtil.roundTo - positive number", ex.getErrorMessage());
            return 0;
        }
    }
    
    // Test roundTo with negative number
    function testRoundToNegative() {
        TestLogger.logTest("MathUtil.roundTo - negative number");
        try {
            var result = MathUtil.roundTo(-2.567, 1);
            Assert.assertApprox(-2.6, result, 0.1, "Should round negative to 1 decimal");
            TestLogger.logPass("MathUtil.roundTo - negative number");
            return 1;
        } catch (ex) {
            TestLogger.logFail("MathUtil.roundTo - negative number", ex.getErrorMessage());
            return 0;
        }
    }
    
    // Test roundTo with zero
    function testRoundToZero() {
        TestLogger.logTest("MathUtil.roundTo - zero");
        try {
            var result = MathUtil.roundTo(0.0, 2);
            Assert.assertApprox(0.0, result, 0.01, "Should handle zero");
            TestLogger.logPass("MathUtil.roundTo - zero");
            return 1;
        } catch (ex) {
            TestLogger.logFail("MathUtil.roundTo - zero", ex.getErrorMessage());
            return 0;
        }
    }
    
    // Test roundTo with multiple decimals
    function testRoundToMultipleDecimals() {
        TestLogger.logTest("MathUtil.roundTo - multiple decimals");
        try {
            var result = MathUtil.roundTo(1.23456789, 4);
            Assert.assertApprox(1.2346, result, 0.0001, "Should round to 4 decimals");
            TestLogger.logPass("MathUtil.roundTo - multiple decimals");
            return 1;
        } catch (ex) {
            TestLogger.logFail("MathUtil.roundTo - multiple decimals", ex.getErrorMessage());
            return 0;
        }
    }
    
    // Test roundTo with .5 boundary (should round up)
    function testRoundToBoundary() {
        TestLogger.logTest("MathUtil.roundTo - .5 boundary");
        try {
            var result = MathUtil.roundTo(2.5, 0);
            Assert.assertApprox(3.0, result, 0.1, "Should round .5 up");
            TestLogger.logPass("MathUtil.roundTo - .5 boundary");
            return 1;
        } catch (ex) {
            TestLogger.logFail("MathUtil.roundTo - .5 boundary", ex.getErrorMessage());
            return 0;
        }
    }
    
    // Test percentage with 0
    function testPercentageZero() {
        TestLogger.logTest("MathUtil.percentage - zero");
        try {
            var result = MathUtil.percentage(0, 100);
            Assert.assertEquals(0, result, "0/100 should be 0%");
            TestLogger.logPass("MathUtil.percentage - zero");
            return 1;
        } catch (ex) {
            TestLogger.logFail("MathUtil.percentage - zero", ex.getErrorMessage());
            return 0;
        }
    }
    
    // Test percentage with mid value
    function testPercentageMid() {
        TestLogger.logTest("MathUtil.percentage - mid value");
        try {
            var result = MathUtil.percentage(50, 100);
            Assert.assertEquals(50, result, "50/100 should be 50%");
            TestLogger.logPass("MathUtil.percentage - mid value");
            return 1;
        } catch (ex) {
            TestLogger.logFail("MathUtil.percentage - mid value", ex.getErrorMessage());
            return 0;
        }
    }
    
    // Test percentage with 100%
    function testPercentage100() {
        TestLogger.logTest("MathUtil.percentage - 100 percent");
        try {
            var result = MathUtil.percentage(100, 100);
            Assert.assertEquals(100, result, "100/100 should be 100%");
            TestLogger.logPass("MathUtil.percentage - 100 percent");
            return 1;
        } catch (ex) {
            TestLogger.logFail("MathUtil.percentage - 100 percent", ex.getErrorMessage());
            return 0;
        }
    }
    
    // Test percentage with negative (clamped to 0)
    function testPercentageBelowZero() {
        TestLogger.logTest("MathUtil.percentage - below zero");
        try {
            var result = MathUtil.percentage(-10, 100);
            Assert.assertEquals(0, result, "Negative should clamp to 0");
            TestLogger.logPass("MathUtil.percentage - below zero");
            return 1;
        } catch (ex) {
            TestLogger.logFail("MathUtil.percentage - below zero", ex.getErrorMessage());
            return 0;
        }
    }
    
    // Test percentage above 100% (clamped to 100)
    function testPercentageAbove100() {
        TestLogger.logTest("MathUtil.percentage - above 100");
        try {
            var result = MathUtil.percentage(150, 100);
            Assert.assertEquals(100, result, "Above 100% should clamp to 100");
            TestLogger.logPass("MathUtil.percentage - above 100");
            return 1;
        } catch (ex) {
            TestLogger.logFail("MathUtil.percentage - above 100", ex.getErrorMessage());
            return 0;
        }
    }
    
    // Test percentage with zero total
    function testPercentageZeroTotal() {
        TestLogger.logTest("MathUtil.percentage - zero total");
        try {
            var result = MathUtil.percentage(50, 0);
            Assert.assertEquals(0, result, "Division by zero should return 0");
            TestLogger.logPass("MathUtil.percentage - zero total");
            return 1;
        } catch (ex) {
            TestLogger.logFail("MathUtil.percentage - zero total", ex.getErrorMessage());
            return 0;
        }
    }

}
