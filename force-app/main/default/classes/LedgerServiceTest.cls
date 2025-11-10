/**
 * @description Test class for LedgerService
 * @group Tests
 */
@IsTest
private class LedgerServiceTest {
    
    @TestSetup
    static void setupTestData() {
        Account distributor = new Account(Name = 'Test Distributor', Type = 'Distributor');
        insert distributor;
        
        Product2 product = new Product2(Name = 'Test Product', ProductCode = 'TEST-001', IsActive = true);
        insert product;
        
        BatchLot__c lot = new BatchLot__c(
            Name = 'LOT-001',
            Product__c = product.Id,
            LotNo__c = 'LOT-001',
            QtyOnHand__c = 0,
            ExpiryDate__c = Date.today().addDays(180)
        );
        insert lot;
    }
    
    @IsTest
    static void testPostMovement_Success() {
        Account distributor = [SELECT Id FROM Account LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        
        Test.startTest();
        InventoryLedger__c entry = LedgerService.postMovement(
            distributor.Id,
            product.Id,
            'StockIn',
            100,
            'GRN',
            'GRN-001'
        );
        Test.stopTest();
        
        System.assertNotEquals(null, entry.Id, 'Entry should be created');
        System.assertEquals(100, entry.Qty__c, 'Quantity should match');
        System.assertEquals('StockIn', entry.MovementType__c, 'Movement type should match');
    }
    
    @IsTest
    static void testPostMovement_Idempotency() {
        Account distributor = [SELECT Id FROM Account LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        
        // Post first time
        InventoryLedger__c entry1 = LedgerService.postMovement(
            distributor.Id,
            product.Id,
            'StockIn',
            100,
            'GRN',
            'GRN-001'
        );
        
        Test.startTest();
        // Post again with same ref
        InventoryLedger__c entry2 = LedgerService.postMovement(
            distributor.Id,
            product.Id,
            'StockIn',
            100,
            'GRN',
            'GRN-001'
        );
        Test.stopTest();
        
        System.assertEquals(entry1.Id, entry2.Id, 'Should return existing entry');
        
        // Verify only one entry exists
        Integer count = [SELECT COUNT() FROM InventoryLedger__c];
        System.assertEquals(1, count, 'Should have only one entry');
    }
    
    @IsTest
    static void testGetStockBalance() {
        Account distributor = [SELECT Id FROM Account LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        
        // Post multiple movements
        LedgerService.postMovement(distributor.Id, product.Id, 'StockIn', 100, 'GRN', 'GRN-001');
        LedgerService.postMovement(distributor.Id, product.Id, 'StockOut', 30, 'Invoice', 'INV-001');
        LedgerService.postMovement(distributor.Id, product.Id, 'StockIn', 50, 'GRN', 'GRN-002');
        
        Test.startTest();
        Decimal balance = LedgerService.getStockBalance(distributor.Id, product.Id);
        Test.stopTest();
        
        System.assertEquals(120, balance, 'Balance should be 100 - 30 + 50 = 120');
    }
    
    @IsTest
    static void testPostMovements_Bulk() {
        Account distributor = [SELECT Id FROM Account LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        
        List<InventoryLedger__c> movements = new List<InventoryLedger__c>();
        for (Integer i = 0; i < 200; i++) {
            movements.add(new InventoryLedger__c(
                Distributor__c = distributor.Id,
                Product__c = product.Id,
                MovementType__c = 'StockIn',
                Qty__c = 10,
                RefId__c = 'GRN:GRN-' + i + ':' + product.Id
            ));
        }
        
        Test.startTest();
        LedgerService.postMovements(movements);
        Test.stopTest();
        
        Integer count = [SELECT COUNT() FROM InventoryLedger__c];
        System.assertEquals(200, count, 'Should create all 200 entries');
    }
}
