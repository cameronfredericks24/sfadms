/**
 * @description Common utility helpers for rounding, JSON serdes, error logging
 * @author RCG Team
 * @date 2024
 */
public with sharing class Util {
    
    /**
     * @description Rounds a decimal to specified scale
     * @param value Value to round
     * @param scale Number of decimal places
     * @return Rounded value
     */
    public static Decimal round(Decimal value, Integer scale) {
        if (value == null) {
            return null;
        }
        return value.setScale(scale, RoundingMode.HALF_UP);
    }
    
    /**
     * @description Serializes object to JSON string
     * @param obj Object to serialize
     * @return JSON string
     */
    public static String toJSON(Object obj) {
        return JSON.serialize(obj);
    }
    
    /**
     * @description Deserializes JSON string to object
     * @param jsonStr JSON string
     * @param type Type to deserialize to
     * @return Deserialized object
     */
    public static Object fromJSON(String jsonStr, Type type) {
        return JSON.deserialize(jsonStr, type);
    }
    
    /**
     * @description Logs error with context
     * @param className Class name
     * @param methodName Method name
     * @param ex Exception
     */
    public static void logError(String className, String methodName, Exception ex) {
        String errorMsg = String.format(
            'Error in {0}.{1}: {2}',
            new String[]{ className, methodName, ex.getMessage() }
        );
        
        // Log to platform event or custom object
        try {
            Logging__e logEvent = new Logging__e(
                ClassName__c = className,
                MethodName__c = methodName,
                ErrorMessage__c = errorMsg,
                StackTrace__c = ex.getStackTraceString()
            );
            EventBus.publish(logEvent);
        } catch (Exception e) {
            // Fallback to system debug
            System.debug(LoggingLevel.ERROR, errorMsg);
        }
    }
    
    /**
     * @description Generates correlation ID
     * @return Correlation ID string
     */
    public static String generateCorrelationId() {
        return String.valueOf(Crypto.getRandomLong());
    }
    
    /**
     * @description Checks if string is blank
     * @param str String to check
     * @return True if blank
     */
    public static Boolean isBlank(String str) {
        return String.isBlank(str);
    }
    
    /**
     * @description Checks if list is empty
     * @param lst List to check
     * @return True if empty
     */
    public static Boolean isEmpty(List<Object> lst) {
        return lst == null || lst.isEmpty();
    }
}
