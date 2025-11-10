/**
 * @description Test class for ReplenishmentService
 * @author RCG Team
 * @date 2024
 */
@isTest
private class ReplenishmentServiceTest {
    
    @testSetup
    static void setupTestData() {
        Account distributor = new Account(Name = 'Test Distributor', Type = 'Distributor');
        insert distributor;
        
        Product2 product = new Product2(Name = 'Test Product', ProductCode = 'PROD-001', IsActive = true);
        insert product;
        
        ReplenishmentPolicy__c policy = new ReplenishmentPolicy__c(
            Distributor__c = distributor.Id,
            Product__c = product.Id,
            MinQty__c = 10,
            MaxQty__c = 1000,
            DaysCover__c = 30,
            SafetyStock__c = 50
        );
        insert policy;
        
        // Create ledger entries for stock out
        List<InventoryLedger__c> ledgers = new List<InventoryLedger__c>();
        for (Integer i = 0; i < 10; i++) {
            ledgers.add(new InventoryLedger__c(
                Distributor__c = distributor.Id,
                Product__c = product.Id,
                MovementType__c = 'StockOut',
                Qty__c = 10,
                RefType__c = 'Invoice',
                RefId__c = 'INV-' + i,
                TxnTs__c = Datetime.now().addDays(-i)
            ));
        }
        insert ledgers;
    }
    
    @isTest
    static void testComputeProposedQty_Success() {
        ReplenishmentPolicy__c policy = [SELECT Id, Distributor__c, Product__c, MinQty__c, MaxQty__c, DaysCover__c, SafetyStock__c FROM ReplenishmentPolicy__c LIMIT 1];
        
        Test.startTest();
        Decimal proposedQty = ReplenishmentService.computeProposedQty(policy);
        Test.stopTest();
        
        System.assert(proposedQty >= 0, 'Proposed quantity should be non-negative');
        System.assert(proposedQty >= policy.MinQty__c, 'Should be at least min quantity');
        System.assert(proposedQty <= policy.MaxQty__c, 'Should be at most max quantity');
    }
}
