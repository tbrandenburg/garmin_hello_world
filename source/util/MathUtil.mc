// MathUtil.mc - Pure mathematical utility functions
// No Toybox dependencies - all functions are pure and testable

module MathUtil {

    // Clamp a value between min and max bounds
    function clamp(value, minValue, maxValue) {
        if (value < minValue) {
            return minValue;
        }
        if (value > maxValue) {
            return maxValue;
        }
        return value;
    }
    
    // Round a value to specified number of decimal places
    // Uses standard rounding rules (0.5 rounds up)
    function roundTo(value, decimals) {
        if (decimals < 0) {
            decimals = 0;
        }
        
        var multiplier = 1;
        for (var i = 0; i < decimals; i++) {
            multiplier *= 10;
        }
        
        var shifted = value * multiplier;
        var rounded = (shifted + 0.5).toNumber();
        
        return rounded.toFloat() / multiplier;
    }
    
    // Calculate percentage (part/total * 100), clamped to 0-100
    // Returns 0 if total is 0 or negative
    function percentage(part, total) {
        if (total <= 0) {
            return 0;
        }
        
        var pct = (part.toFloat() / total.toFloat()) * 100.0;
        
        // Clamp to 0-100 range
        if (pct < 0) {
            return 0;
        }
        if (pct > 100) {
            return 100;
        }
        
        return pct.toNumber();
    }

}
