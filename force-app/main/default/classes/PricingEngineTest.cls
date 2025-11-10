/**
 * @description Test class for PricingEngine
 */
@isTest
private class PricingEngineTest {
    
    @testSetup
    static void setup() {
        // Create test accounts
        Account distributor = new Account(
            Name = 'Test Distributor',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                .get('Distributor').getRecordTypeId()
        );
        Account retailer = new Account(
            Name = 'Test Retailer',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                .get('Retailer').getRecordTypeId()
        );
        insert new List<Account>{ distributor, retailer };
        
        // Create products
        Product2 product = new Product2(
            Name = 'Test Product',
            IsActive = true,
            ProductCode = 'TEST-001'
        );
        insert product;
        
        // Create pricebook entry
        Pricebook2 standardPb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = standardPb.Id,
            Product2Id = product.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbe;
        
        // Create promotion
        Promotion__c promo = new Promotion__c(
            ProgramType__c = 'Volume',
            BudgetAmount__c = 10000,
            StartDate__c = Date.today().addDays(-10),
            EndDate__c = Date.today().addDays(10),
            Active__c = true
        );
        insert promo;
        
        // Create order
        SecondaryOrder__c order = new SecondaryOrder__c(
            Retailer__c = retailer.Id,
            Distributor__c = distributor.Id,
            Status__c = 'Draft'
        );
        insert order;
        
        // Create order line
        SecondaryOrderLine__c line = new SecondaryOrderLine__c(
            SecondaryOrder__c = order.Id,
            Product__c = product.Id,
            QtyBase__c = 10,
            UoM__c = 'EA'
        );
        insert line;
    }
    
    @isTest
    static void testApplyPricing() {
        SecondaryOrder__c order = [SELECT Id FROM SecondaryOrder__c LIMIT 1];
        List<SecondaryOrderLine__c> lines = [SELECT Id FROM SecondaryOrderLine__c];
        
        PricingEngine.PricingRequest req = new PricingEngine.PricingRequest();
        req.orderId = order.Id;
        req.orderLineIds = new List<Id>{ lines[0].Id };
        
        Test.startTest();
        List<PricingEngine.PricingResult> results = PricingEngine.applyPricing(new List<PricingEngine.PricingRequest>{ req });
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(true, results[0].success);
        
        // Verify order totals
        order = [SELECT GrossAmount__c, NetAmount__c, TaxAmount__c FROM SecondaryOrder__c WHERE Id = :order.Id];
        System.assertNotEquals(null, order.GrossAmount__c);
        System.assertNotEquals(null, order.NetAmount__c);
        System.assertNotEquals(null, order.TaxAmount__c);
    }
    
    @isTest
    static void testApplyPricingWithError() {
        PricingEngine.PricingRequest req = new PricingEngine.PricingRequest();
        req.orderId = null; // Invalid ID
        
        Test.startTest();
        List<PricingEngine.PricingResult> results = PricingEngine.applyPricing(new List<PricingEngine.PricingRequest>{ req });
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(false, results[0].success);
        System.assertNotEquals(null, results[0].errorMessage);
    }
}
