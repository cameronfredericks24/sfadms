/**
 * @description Utility class with common helpers
 * @group Utilities
 */
public with sharing class Util {
    
    /**
     * @description Log an error for troubleshooting
     */
    public static void logError(String context, Exception e) {
        System.debug(LoggingLevel.ERROR, context + ': ' + e.getMessage() + '\n' + e.getStackTraceString());
        
        // In production, would write to Logging__c or platform event
        // For now, just debug log
    }
    
    /**
     * @description Round currency to 2 decimal places
     */
    public static Decimal roundCurrency(Decimal amount) {
        return amount != null ? amount.setScale(2, RoundingMode.HALF_UP) : 0;
    }
    
    /**
     * @description Safe JSON deserialization
     */
    public static Map<String, Object> deserializeJSON(String jsonString) {
        try {
            return (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        } catch (Exception e) {
            logError('Util.deserializeJSON', e);
            return new Map<String, Object>();
        }
    }
    
    /**
     * @description Calculate distance between two GPS coordinates (Haversine formula)
     */
    public static Decimal calculateDistance(Decimal lat1, Decimal lon1, Decimal lat2, Decimal lon2) {
        if (lat1 == null || lon1 == null || lat2 == null || lon2 == null) {
            return null;
        }
        
        Decimal earthRadius = 6371; // km
        Decimal dLat = toRadians(lat2 - lat1);
        Decimal dLon = toRadians(lon2 - lon1);
        
        Decimal a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                    Math.cos(toRadians(lat1)) * Math.cos(toRadians(lat2)) *
                    Math.sin(dLon / 2) * Math.sin(dLon / 2);
        
        Decimal c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        Decimal distance = earthRadius * c * 1000; // Convert to meters
        
        return distance.setScale(2);
    }
    
    /**
     * @description Convert degrees to radians
     */
    private static Decimal toRadians(Decimal degrees) {
        return degrees * Math.PI / 180;
    }
}
