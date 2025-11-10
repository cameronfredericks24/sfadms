/**
 * @description Idempotent inventory ledger service
 */
public with sharing class LedgerService {
    
    public static void postStockMovement(
        Id distributorId,
        Id productId,
        String movementType,
        Decimal qty,
        Decimal unitCost,
        Id batchLotId,
        String refType,
        String refId
    ) {
        // Check for existing entry (idempotency)
        List<InventoryLedger__c> existing = [
            SELECT Id
            FROM InventoryLedger__c
            WHERE RefType__c = :refType
            AND RefId__c = :refId
            LIMIT 1
        ];
        
        if (!existing.isEmpty()) {
            // Already posted - idempotent
            return;
        }
        
        // Create ledger entry
        InventoryLedger__c ledger = new InventoryLedger__c(
            Distributor__c = distributorId,
            Product__c = productId,
            MovementType__c = movementType,
            Qty__c = qty,
            UnitCost__c = unitCost,
            BatchLot__c = batchLotId,
            RefType__c = refType,
            RefId__c = refId,
            TxnTs__c = Datetime.now()
        );
        
        insert ledger;
    }
    
    public static void postBulkMovements(List<LedgerEntry> entries) {
        List<InventoryLedger__c> ledgers = new List<InventoryLedger__c>();
        Set<String> refKeys = new Set<String>();
        
        // Build ref keys for idempotency check
        for (LedgerEntry entry : entries) {
            refKeys.add(entry.refType + '|' + entry.refId);
        }
        
        // Check existing entries
        Map<String, InventoryLedger__c> existingMap = new Map<String, InventoryLedger__c>();
        for (InventoryLedger__c existing : [
            SELECT RefType__c, RefId__c
            FROM InventoryLedger__c
            WHERE RefType__c IN :new Set<String>(new List<String>(refKeys))
        ]) {
            String key = existing.RefType__c + '|' + existing.RefId__c;
            existingMap.put(key, existing);
        }
        
        // Create new entries
        for (LedgerEntry entry : entries) {
            String key = entry.refType + '|' + entry.refId;
            if (existingMap.containsKey(key)) {
                continue; // Skip - already exists
            }
            
            ledgers.add(new InventoryLedger__c(
                Distributor__c = entry.distributorId,
                Product__c = entry.productId,
                MovementType__c = entry.movementType,
                Qty__c = entry.qty,
                UnitCost__c = entry.unitCost,
                BatchLot__c = entry.batchLotId,
                RefType__c = entry.refType,
                RefId__c = entry.refId,
                TxnTs__c = Datetime.now()
            ));
        }
        
        if (!ledgers.isEmpty()) {
            insert ledgers;
        }
    }
    
    public class LedgerEntry {
        public Id distributorId;
        public Id productId;
        public String movementType;
        public Decimal qty;
        public Decimal unitCost;
        public Id batchLotId;
        public String refType;
        public String refId;
    }
}
