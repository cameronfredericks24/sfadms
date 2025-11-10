/**
 * @description Utility class with common helpers
 */
public with sharing class Util {
    
    public static Decimal roundCurrency(Decimal amount) {
        if (amount == null) {
            return 0;
        }
        return amount.setScale(2, System.RoundingMode.HALF_UP);
    }
    
    public static Decimal roundQuantity(Decimal qty) {
        if (qty == null) {
            return 0;
        }
        return qty.setScale(3, System.RoundingMode.HALF_UP);
    }
    
    public static Map<String, Object> parseJSON(String jsonString) {
        if (String.isBlank(jsonString)) {
            return new Map<String, Object>();
        }
        try {
            return (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        } catch (Exception e) {
            rcg.Logging.logError('Util', 'parseJSON', e);
            return new Map<String, Object>();
        }
    }
    
    public static String serializeJSON(Object obj) {
        try {
            return JSON.serialize(obj);
        } catch (Exception e) {
            rcg.Logging.logError('Util', 'serializeJSON', e);
            return '{}';
        }
    }
    
    public static Decimal calculateDistance(Decimal lat1, Decimal lon1, Decimal lat2, Decimal lon2) {
        if (lat1 == null || lon1 == null || lat2 == null || lon2 == null) {
            return null;
        }
        
        // Haversine formula for distance calculation
        Decimal R = 6371000; // Earth radius in meters
        Decimal dLat = (lat2 - lat1) * Math.PI / 180;
        Decimal dLon = (lon2 - lon1) * Math.PI / 180;
        Decimal a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                   Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
                   Math.sin(dLon / 2) * Math.sin(dLon / 2);
        Decimal c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        Decimal distance = R * c;
        
        return distance;
    }
}
