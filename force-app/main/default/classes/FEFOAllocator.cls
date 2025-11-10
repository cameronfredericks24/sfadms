/**
 * @description First Expiry First Out (FEFO) batch lot allocator
 */
public with sharing class FEFOAllocator {
    
    public static BatchLot__c allocateBatchLot(Id productId, Decimal qty, Date thresholdDate) {
        // Find available batch lots ordered by expiry date (FEFO)
        List<BatchLot__c> availableLots = [
            SELECT Id, LotNo__c, ExpiryDate__c, QtyOnHand__c, Status__c
            FROM BatchLot__c
            WHERE Product__c = :productId
            AND Status__c = 'Available'
            AND QtyOnHand__c > 0
            AND (ExpiryDate__c >= :thresholdDate OR ExpiryDate__c = null)
            ORDER BY ExpiryDate__c ASC NULLS LAST
            LIMIT 100
        ];
        
        if (availableLots.isEmpty()) {
            throw new FEFOException('No available batch lots found for product: ' + productId);
        }
        
        // Check if earliest expiry is within threshold
        BatchLot__c earliestLot = availableLots[0];
        if (thresholdDate != null && earliestLot.ExpiryDate__c != null && 
            earliestLot.ExpiryDate__c < thresholdDate) {
            throw new FEFOException('Earliest batch lot expires before threshold date: ' + 
                                   earliestLot.ExpiryDate__c);
        }
        
        // Allocate from first lot if sufficient quantity
        if (earliestLot.QtyOnHand__c >= qty) {
            return earliestLot;
        }
        
        // Otherwise, need to allocate from multiple lots (simplified - return first)
        // TODO: Implement multi-lot allocation logic
        return earliestLot;
    }
    
    public static List<BatchLot__c> allocateMultipleLots(Id productId, Decimal qty, Date thresholdDate) {
        List<BatchLot__c> allocatedLots = new List<BatchLot__c>();
        Decimal remainingQty = qty;
        
        List<BatchLot__c> availableLots = [
            SELECT Id, LotNo__c, ExpiryDate__c, QtyOnHand__c, Status__c
            FROM BatchLot__c
            WHERE Product__c = :productId
            AND Status__c = 'Available'
            AND QtyOnHand__c > 0
            AND (ExpiryDate__c >= :thresholdDate OR ExpiryDate__c = null)
            ORDER BY ExpiryDate__c ASC NULLS LAST
        ];
        
        for (BatchLot__c lot : availableLots) {
            if (remainingQty <= 0) {
                break;
            }
            
            Decimal allocateQty = Math.min(remainingQty, lot.QtyOnHand__c);
            allocatedLots.add(lot);
            remainingQty -= allocateQty;
        }
        
        if (remainingQty > 0) {
            throw new FEFOException('Insufficient batch lot quantity. Remaining: ' + remainingQty);
        }
        
        return allocatedLots;
    }
    
    public class FEFOException extends Exception {}
}
