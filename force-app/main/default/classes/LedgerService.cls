/**
 * @description Service for idempotent inventory ledger operations
 * @group Inventory
 */
public with sharing class LedgerService {
    
    /**
     * @description Post inventory movement to ledger (idempotent by RefType+RefId)
     */
    public static InventoryLedger__c postMovement(
        Id distributorId,
        Id productId,
        String movementType,
        Decimal qty,
        String refType,
        String refId
    ) {
        // Check if entry already exists (idempotency)
        String uniqueKey = refType + ':' + refId + ':' + productId;
        List<InventoryLedger__c> existing = [
            SELECT Id, Qty__c
            FROM InventoryLedger__c
            WHERE RefId__c = :uniqueKey
            LIMIT 1
        ];
        
        if (!existing.isEmpty()) {
            return existing[0]; // Already posted
        }
        
        // Create new ledger entry
        InventoryLedger__c entry = new InventoryLedger__c(
            Distributor__c = distributorId,
            Product__c = productId,
            MovementType__c = movementType,
            Qty__c = qty,
            RefId__c = uniqueKey
        );
        
        insert entry;
        
        // Update batch lot quantities if applicable
        updateBatchLotQuantity(productId, qty, movementType);
        
        return entry;
    }
    
    /**
     * @description Post multiple movements in bulk
     */
    public static List<InventoryLedger__c> postMovements(List<InventoryLedger__c> movements) {
        // Collect unique keys
        Set<String> refIds = new Set<String>();
        for (InventoryLedger__c movement : movements) {
            refIds.add(movement.RefId__c);
        }
        
        // Check existing
        Map<String, InventoryLedger__c> existingMap = new Map<String, InventoryLedger__c>();
        for (InventoryLedger__c existing : [SELECT Id, RefId__c FROM InventoryLedger__c WHERE RefId__c IN :refIds]) {
            existingMap.put(existing.RefId__c, existing);
        }
        
        // Insert only new entries
        List<InventoryLedger__c> toInsert = new List<InventoryLedger__c>();
        for (InventoryLedger__c movement : movements) {
            if (!existingMap.containsKey(movement.RefId__c)) {
                toInsert.add(movement);
            }
        }
        
        if (!toInsert.isEmpty()) {
            insert toInsert;
        }
        
        return movements;
    }
    
    /**
     * @description Update batch lot quantity based on movement
     */
    @TestVisible
    private static void updateBatchLotQuantity(Id productId, Decimal qty, String movementType) {
        // Find batch lots for this product
        List<BatchLot__c> lots = [
            SELECT Id, QtyOnHand__c
            FROM BatchLot__c
            WHERE Product__c = :productId
            ORDER BY ExpiryDate__c ASC
            LIMIT 1
        ];
        
        if (!lots.isEmpty()) {
            BatchLot__c lot = lots[0];
            if (movementType == 'StockIn') {
                lot.QtyOnHand__c += qty;
            } else if (movementType == 'StockOut') {
                lot.QtyOnHand__c -= qty;
            }
            update lot;
        }
    }
    
    /**
     * @description Get current stock balance for a product
     */
    public static Decimal getStockBalance(Id distributorId, Id productId) {
        AggregateResult[] results = [
            SELECT SUM(Qty__c) balance
            FROM InventoryLedger__c
            WHERE Distributor__c = :distributorId
              AND Product__c = :productId
        ];
        
        if (!results.isEmpty() && results[0].get('balance') != null) {
            return (Decimal) results[0].get('balance');
        }
        
        return 0;
    }
}
