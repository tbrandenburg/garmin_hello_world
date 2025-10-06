using Toybox.Test as Test;
using MathUtil;
using Assert;

class MathUtilTestCase extends Test.TestCase {

    function initialize() {
        Test.TestCase.initialize(self, "MathUtil");
    }

    function testClampBounds() {
        Assert.assertEquals(10, MathUtil.clamp(5, 10, 20), "Values below min clamp to min");
        Assert.assertEquals(15, MathUtil.clamp(15, 10, 20), "Values inside range pass through");
        Assert.assertEquals(20, MathUtil.clamp(25, 10, 20), "Values above max clamp to max");
    }

    function testRoundTo() {
        Assert.assertApprox(3.14, MathUtil.roundTo(3.14159, 2), 0.01, "Rounds positives to requested precision");
        Assert.assertApprox(-2.6, MathUtil.roundTo(-2.567, 1), 0.1, "Rounds negatives symmetrically");
        Assert.assertApprox(0.0, MathUtil.roundTo(0.0, 2), 0.01, "Handles zero");
        Assert.assertApprox(1.2346, MathUtil.roundTo(1.23456789, 4), 0.0001, "Supports deep precision");
        Assert.assertApprox(3.0, MathUtil.roundTo(2.5, 0), 0.1, "Rounds .5 boundaries up");
    }

    function testPercentage() {
        Assert.assertEquals(0, MathUtil.percentage(0, 100), "0/100 => 0%");
        Assert.assertEquals(50, MathUtil.percentage(50, 100), "50/100 => 50%");
        Assert.assertEquals(100, MathUtil.percentage(150, 100), "Upper bound clamps to 100%");
        Assert.assertEquals(0, MathUtil.percentage(-10, 100), "Negative parts clamp to 0%");
        Assert.assertEquals(0, MathUtil.percentage(10, 0), "Zero denominator returns 0%");
    }
}
