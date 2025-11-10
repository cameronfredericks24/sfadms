/**
 * @description Test class for LedgerService
 * @author RCG Team
 * @date 2024
 */
@isTest
private class LedgerServiceTest {
    
    @testSetup
    static void setupTestData() {
        Account distributor = new Account(Name = 'Test Distributor', Type = 'Distributor');
        insert distributor;
        
        Product2 product = new Product2(Name = 'Test Product', ProductCode = 'PROD-001', IsActive = true);
        insert product;
    }
    
    @isTest
    static void testCreateLedgerEntry_Success() {
        Account distributor = [SELECT Id FROM Account WHERE Type = 'Distributor' LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        
        Test.startTest();
        Id ledgerId = LedgerService.createLedgerEntry(
            distributor.Id,
            product.Id,
            'StockIn',
            100,
            50.00,
            null,
            'GRN',
            'GRN-001'
        );
        Test.stopTest();
        
        System.assertNotEquals(null, ledgerId, 'Should create ledger entry');
        
        InventoryLedger__c ledger = [
            SELECT Id, Qty__c, RefType__c, RefId__c
            FROM InventoryLedger__c
            WHERE Id = :ledgerId
        ];
        System.assertEquals(100, ledger.Qty__c, 'Quantity should match');
        System.assertEquals('GRN', ledger.RefType__c, 'Ref type should match');
        System.assertEquals('GRN-001', ledger.RefId__c, 'Ref ID should match');
    }
    
    @isTest
    static void testCreateLedgerEntry_Idempotent() {
        Account distributor = [SELECT Id FROM Account WHERE Type = 'Distributor' LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        
        // Create first entry
        Id ledgerId1 = LedgerService.createLedgerEntry(
            distributor.Id,
            product.Id,
            'StockIn',
            100,
            50.00,
            null,
            'GRN',
            'GRN-001'
        );
        
        Test.startTest();
        // Try to create duplicate
        Id ledgerId2 = LedgerService.createLedgerEntry(
            distributor.Id,
            product.Id,
            'StockIn',
            100,
            50.00,
            null,
            'GRN',
            'GRN-001'
        );
        Test.stopTest();
        
        System.assertEquals(ledgerId1, ledgerId2, 'Should return existing entry');
        
        List<InventoryLedger__c> ledgers = [
            SELECT Id FROM InventoryLedger__c WHERE RefId__c = 'GRN-001'
        ];
        System.assertEquals(1, ledgers.size(), 'Should have only one entry');
    }
}
