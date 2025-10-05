// StringUtil.mc - Pure string manipulation utilities
// No Toybox dependencies - all functions are pure and testable

module StringUtil {

    // Format seconds into mm:ss or hh:mm:ss format
    // Returns "00:00" for negative values
    function formatTime(seconds) {
        if (seconds < 0) {
            return "00:00";
        }
        
        var hours = seconds / 3600;
        var mins = (seconds % 3600) / 60;
        var secs = seconds % 60;
        
        if (hours > 0) {
            return hours.format("%d") + ":" + 
                   mins.format("%02d") + ":" + 
                   secs.format("%02d");
        } else {
            return mins.format("%02d") + ":" + 
                   secs.format("%02d");
        }
    }
    
    // Capitalize the first character of a string
    // Returns empty string for empty input
    function capitalize(str) {
        if (str == null || str.length() == 0) {
            return "";
        }
        
        var firstChar = str.substring(0, 1);
        var rest = str.substring(1, str.length());
        
        // Convert first character to uppercase (simple ASCII approach)
        var code = firstChar.toCharArray()[0];
        if (code >= 'a' && code <= 'z') {
            code = code - 32; // Convert to uppercase
            firstChar = code.toChar().toString();
        }
        
        return firstChar + rest;
    }
    
    // Truncate string to maxLen characters, optionally adding "..." if truncated
    // If addEllipsis is true and string is truncated, ellipsis counts toward maxLen
    function truncate(str, maxLen, addEllipsis) {
        if (str == null) {
            return "";
        }
        
        if (str.length() <= maxLen) {
            return str;
        }
        
        if (addEllipsis) {
            // Reserve 3 chars for "..." if maxLen allows
            if (maxLen <= 3) {
                return str.substring(0, maxLen);
            }
            return str.substring(0, maxLen - 3) + "...";
        } else {
            return str.substring(0, maxLen);
        }
    }

}
