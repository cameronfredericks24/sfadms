/**
 * @description Platform events or custom object Logging__c for correlation IDs
 * @author RCG Team
 * @date 2024
 */
public with sharing class Logging {
    
    /**
     * @description Logs message to platform event
     * @param level Log level
     * @param message Log message
     * @param correlationId Correlation ID
     */
    public static void log(String level, String message, String correlationId) {
        try {
            Logging__e logEvent = new Logging__e(
                Level__c = level,
                Message__c = message,
                CorrelationId__c = correlationId,
                Timestamp__c = Datetime.now()
            );
            EventBus.publish(logEvent);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Failed to publish log event: ' + e.getMessage());
        }
    }
    
    /**
     * @description Logs error with exception
     * @param message Error message
     * @param ex Exception
     * @param correlationId Correlation ID
     */
    public static void logError(String message, Exception ex, String correlationId) {
        log('ERROR', message + ': ' + ex.getMessage(), correlationId);
    }
    
    /**
     * @description Logs info message
     * @param message Info message
     * @param correlationId Correlation ID
     */
    public static void logInfo(String message, String correlationId) {
        log('INFO', message, correlationId);
    }
}
