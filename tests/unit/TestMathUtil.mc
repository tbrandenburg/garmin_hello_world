// TestMathUtil.mc - Function-based tests for MathUtil module
// Uses Connect IQ's function-based testing with :test annotations

using Toybox.Test as Test;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using MathUtil;

// Test clamping function bounds checking
(:test)
function testMathUtilClampBounds(logger as Test.Logger) as Lang.Boolean {
    logger.debug("Testing MathUtil.clamp() bounds checking");
    
    // Values below min should clamp to min
    Test.assertEqual(10, MathUtil.clamp(5, 10, 20));
    
    // Values inside range should pass through unchanged
    Test.assertEqual(15, MathUtil.clamp(15, 10, 20));
    
    // Values above max should clamp to max
    Test.assertEqual(20, MathUtil.clamp(25, 10, 20));
    
    logger.debug("MathUtil.clamp() bounds tests completed");
    return true;
}

// Test rounding function precision handling
(:test)
function testMathUtilRoundTo(logger as Test.Logger) as Lang.Boolean {
    logger.debug("Testing MathUtil.roundTo() precision handling");
    
    // Test positive number rounding
    var result1 = MathUtil.roundTo(3.14159, 2);
    Test.assert((result1 - 3.14).abs() < 0.01);
    
    // Test negative number rounding
    var result2 = MathUtil.roundTo(-2.567, 1);
    Test.assert((result2 - (-2.6)).abs() < 0.1);
    
    // Test zero handling
    var result3 = MathUtil.roundTo(0.0, 2);
    Test.assert((result3 - 0.0).abs() < 0.01);
    
    // Test deep precision
    var result4 = MathUtil.roundTo(1.23456789, 4);
    Test.assert((result4 - 1.2346).abs() < 0.0001);
    
    // Test .5 boundary rounding (should round up)
    var result5 = MathUtil.roundTo(2.5, 0);
    Test.assert((result5 - 3.0).abs() < 0.1);
    
    logger.debug("MathUtil.roundTo() precision tests completed");
    return true;
}

// Test percentage calculation function
(:test)
function testMathUtilPercentage(logger as Test.Logger) as Lang.Boolean {
    logger.debug("Testing MathUtil.percentage() calculation");
    
    // Test zero percentage
    Test.assertEqual(0, MathUtil.percentage(0, 100));
    
    // Test normal percentage
    Test.assertEqual(50, MathUtil.percentage(50, 100));
    
    // Test upper bound clamping
    Test.assertEqual(100, MathUtil.percentage(150, 100));
    
    // Test negative part clamping
    Test.assertEqual(0, MathUtil.percentage(-10, 100));
    
    // Test zero denominator handling
    Test.assertEqual(0, MathUtil.percentage(10, 0));
    
    logger.debug("MathUtil.percentage() tests completed");
    return true;
}
