/**
 * @description Idempotent writes to InventoryLedger__c (RefType/RefId key)
 * @author RCG Team
 * @date 2024
 */
public with sharing class LedgerService {
    
    /**
     * @description Creates ledger entry idempotently
     * @param distributorId Distributor ID
     * @param productId Product ID
     * @param movementType Movement type
     * @param qty Quantity
     * @param unitCost Unit cost
     * @param batchLotId Batch lot ID
     * @param refType Reference type
     * @param refId Reference ID
     * @return Created ledger entry ID
     */
    public static Id createLedgerEntry(
        Id distributorId,
        Id productId,
        String movementType,
        Decimal qty,
        Decimal unitCost,
        Id batchLotId,
        String refType,
        String refId
    ) {
        // Check if entry already exists (idempotency check)
        List<InventoryLedger__c> existing = [
            SELECT Id
            FROM InventoryLedger__c
            WHERE RefType__c = :refType
            AND RefId__c = :refId
            LIMIT 1
        ];
        
        if (!existing.isEmpty()) {
            return existing[0].Id;
        }
        
        // Create new ledger entry
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
        return ledger.Id;
    }
    
    /**
     * @description Creates ledger entries in bulk
     * @param entries List of ledger entries
     * @return List of created ledger entry IDs
     */
    public static List<Id> createLedgerEntries(List<LedgerEntry> entries) {
        List<InventoryLedger__c> ledgers = new List<InventoryLedger__c>();
        Set<String> refKeys = new Set<String>();
        
        // Build ref keys for idempotency check
        for (LedgerEntry entry : entries) {
            refKeys.add(entry.refType + '|' + entry.refId);
        }
        
        // Query existing entries
        List<InventoryLedger__c> existing = [
            SELECT Id, RefType__c, RefId__c
            FROM InventoryLedger__c
            WHERE RefType__c IN :getRefTypes(entries)
            AND RefId__c IN :getRefIds(entries)
        ];
        
        Map<String, Id> existingMap = new Map<String, Id>();
        for (InventoryLedger__c ledger : existing) {
            existingMap.put(ledger.RefType__c + '|' + ledger.RefId__c, ledger.Id);
        }
        
        // Create new entries
        for (LedgerEntry entry : entries) {
            String refKey = entry.refType + '|' + entry.refId;
            if (existingMap.containsKey(refKey)) {
                continue; // Skip if already exists
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
        
        List<Id> result = new List<Id>();
        for (InventoryLedger__c ledger : ledgers) {
            result.add(ledger.Id);
        }
        
        return result;
    }
    
    private static Set<String> getRefTypes(List<LedgerEntry> entries) {
        Set<String> refTypes = new Set<String>();
        for (LedgerEntry entry : entries) {
            refTypes.add(entry.refType);
        }
        return refTypes;
    }
    
    private static Set<String> getRefIds(List<LedgerEntry> entries) {
        Set<String> refIds = new Set<String>();
        for (LedgerEntry entry : entries) {
            refIds.add(entry.refId);
        }
        return refIds;
    }
    
    /**
     * @description Ledger entry wrapper
     */
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
