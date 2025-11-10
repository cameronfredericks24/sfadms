/**
 * @description Test class for LedgerService
 */
@isTest
private class LedgerServiceTest {
    
    @testSetup
    static void setup() {
        Account distributor = new Account(Name = 'Test Distributor');
        insert distributor;
        
        Product2 product = new Product2(
            Name = 'Test Product',
            IsActive = true,
            ProductCode = 'TEST-001'
        );
        insert product;
    }
    
    @isTest
    static void testPostStockMovement() {
        Account distributor = [SELECT Id FROM Account LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        
        Test.startTest();
        LedgerService.postStockMovement(
            distributor.Id,
            product.Id,
            'StockIn',
            100,
            10.00,
            null,
            'GRN',
            'GRN-001'
        );
        Test.stopTest();
        
        List<InventoryLedger__c> ledgers = [
            SELECT Id, RefType__c, RefId__c, Qty__c
            FROM InventoryLedger__c
        ];
        System.assertEquals(1, ledgers.size());
        System.assertEquals('GRN-001', ledgers[0].RefId__c);
    }
    
    @isTest
    static void testPostStockMovementIdempotent() {
        Account distributor = [SELECT Id FROM Account LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        
        // Post first time
        LedgerService.postStockMovement(
            distributor.Id,
            product.Id,
            'StockIn',
            100,
            10.00,
            null,
            'GRN',
            'GRN-001'
        );
        
        Test.startTest();
        // Post second time with same ref - should be idempotent
        LedgerService.postStockMovement(
            distributor.Id,
            product.Id,
            'StockIn',
            100,
            10.00,
            null,
            'GRN',
            'GRN-001'
        );
        Test.stopTest();
        
        List<InventoryLedger__c> ledgers = [
            SELECT Id FROM InventoryLedger__c
        ];
        System.assertEquals(1, ledgers.size()); // Still only one entry
    }
    
    @isTest
    static void testPostBulkMovements() {
        Account distributor = [SELECT Id FROM Account LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        
        List<LedgerService.LedgerEntry> entries = new List<LedgerService.LedgerEntry>();
        for (Integer i = 0; i < 5; i++) {
            LedgerService.LedgerEntry entry = new LedgerService.LedgerEntry();
            entry.distributorId = distributor.Id;
            entry.productId = product.Id;
            entry.movementType = 'StockIn';
            entry.qty = 100;
            entry.unitCost = 10.00;
            entry.refType = 'GRN';
            entry.refId = 'GRN-' + i;
            entries.add(entry);
        }
        
        Test.startTest();
        LedgerService.postBulkMovements(entries);
        Test.stopTest();
        
        List<InventoryLedger__c> ledgers = [
            SELECT Id FROM InventoryLedger__c
        ];
        System.assertEquals(5, ledgers.size());
    }
}
