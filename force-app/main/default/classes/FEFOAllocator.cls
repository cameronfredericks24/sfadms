/**
 * @description Allocates BatchLot__c on dispatch; blocks if ExpiryDate__c < threshold
 * @author RCG Team
 * @date 2024
 */
public with sharing class FEFOAllocator {
    
    private static final Integer EXPIRY_THRESHOLD_DAYS = 30;
    
    /**
     * @description Allocates batch lot for an order line using FEFO (First Expiry First Out)
     * @param orderLine Order line
     * @param productId Product ID
     * @param qty Quantity required
     * @return Allocated batch lot ID
     */
    public static Id allocateBatchLot(SecondaryOrderLine__c orderLine, Id productId, Decimal qty) {
        // Query available batch lots for product, ordered by expiry date (FEFO)
        List<BatchLot__c> availableLots = [
            SELECT Id, ExpiryDate__c, QtyOnHand__c, Status__c
            FROM BatchLot__c
            WHERE Product__c = :productId
            AND Status__c = 'Available'
            AND QtyOnHand__c > 0
            AND ExpiryDate__c >= :Date.today().addDays(EXPIRY_THRESHOLD_DAYS)
            ORDER BY ExpiryDate__c ASC, MfgDate__c ASC
            LIMIT 100
        ];
        
        if (availableLots.isEmpty()) {
            throw new FEFOException('No available batch lots found for product: ' + productId);
        }
        
        // Allocate from first lot (FEFO)
        BatchLot__c allocatedLot = availableLots[0];
        
        // Check if lot has sufficient quantity
        if (allocatedLot.QtyOnHand__c < qty) {
            throw new FEFOException('Insufficient quantity in batch lot. Available: ' + allocatedLot.QtyOnHand__c + ', Required: ' + qty);
        }
        
        // Check expiry threshold
        if (allocatedLot.ExpiryDate__c < Date.today().addDays(EXPIRY_THRESHOLD_DAYS)) {
            throw new FEFOException('Batch lot expires within threshold period. Expiry: ' + allocatedLot.ExpiryDate__c);
        }
        
        // Update order line with batch lot
        orderLine.BatchLot__c = allocatedLot.Id;
        
        return allocatedLot.Id;
    }
    
    /**
     * @description Custom exception for FEFO allocation errors
     */
    public class FEFOException extends Exception {}
}
