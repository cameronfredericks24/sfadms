/**
 * @description Test class for ReplenishmentService
 */
@isTest
private class ReplenishmentServiceTest {
    
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
        
        ReplenishmentPolicy__c policy = new ReplenishmentPolicy__c(
            Distributor__c = distributor.Id,
            Product__c = product.Id,
            MinQty__c = 10,
            MaxQty__c = 1000,
            DaysCover__c = 30,
            SafetyStock__c = 50,
            LeadTimeDays__c = 7,
            AutoFlag__c = false
        );
        insert policy;
    }
    
    @isTest
    static void testCalculateProposal() {
        ReplenishmentPolicy__c policy = [SELECT Id FROM ReplenishmentPolicy__c LIMIT 1];
        Decimal currentStock = 100;
        Decimal avgDailyDemand = 10;
        
        Test.startTest();
        ReplenishmentProposal__c proposal = ReplenishmentService.calculateProposal(
            policy,
            currentStock,
            avgDailyDemand
        );
        Test.stopTest();
        
        System.assertNotEquals(null, proposal);
        System.assert(proposal.ProposedQty__c > 0);
    }
    
    @isTest
    static void testCalculateAverageDailyDemand() {
        Account distributor = [SELECT Id FROM Account LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        
        // Create ledger entries
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
        
        Test.startTest();
        Decimal avgDemand = ReplenishmentService.calculateAverageDailyDemand(
            distributor.Id,
            product.Id,
            30
        );
        Test.stopTest();
        
        System.assert(avgDemand > 0);
    }
}
