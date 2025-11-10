/**
 * @description Test class for PricingEngine
 * @author RCG Team
 * @date 2024
 */
@isTest
private class PricingEngineTest {
    
    @testSetup
    static void setupTestData() {
        // Create accounts
        Account distributor = new Account(
            Name = 'Test Distributor',
            Type = 'Distributor'
        );
        Account retailer = new Account(
            Name = 'Test Retailer',
            Type = 'Retailer'
        );
        insert new List<Account>{ distributor, retailer };
        
        // Create products
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < 5; i++) {
            products.add(new Product2(
                Name = 'Test Product ' + i,
                ProductCode = 'PROD-' + i,
                IsActive = true
            ));
        }
        insert products;
        
        // Create pricebook entries
        Id pricebookId = Test.getStandardPricebookId();
        List<PricebookEntry> entries = new List<PricebookEntry>();
        for (Product2 prod : products) {
            entries.add(new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = prod.Id,
                UnitPrice = 100.00,
                IsActive = true
            ));
        }
        insert entries;
        
        // Create secondary order
        SecondaryOrder__c order = new SecondaryOrder__c(
            Retailer__c = retailer.Id,
            Distributor__c = distributor.Id,
            Status__c = 'Draft'
        );
        insert order;
        
        // Create order lines
        List<SecondaryOrderLine__c> lines = new List<SecondaryOrderLine__c>();
        for (Product2 prod : products) {
            lines.add(new SecondaryOrderLine__c(
                SecondaryOrder__c = order.Id,
                Product__c = prod.Id,
                QtyDisplay__c = '10',
                UoM__c = 'EA'
            ));
        }
        insert lines;
    }
    
    @isTest
    static void testApplyPricing_Success() {
        SecondaryOrder__c order = [SELECT Id FROM SecondaryOrder__c LIMIT 1];
        List<SecondaryOrderLine__c> lines = [
            SELECT Id FROM SecondaryOrderLine__c WHERE SecondaryOrder__c = :order.Id
        ];
        
        List<Id> lineIds = new List<Id>();
        for (SecondaryOrderLine__c line : lines) {
            lineIds.add(line.Id);
        }
        
        PricingEngine.PricingRequest req = new PricingEngine.PricingRequest();
        req.orderId = order.Id;
        req.orderLineIds = lineIds;
        
        Test.startTest();
        List<PricingEngine.PricingResult> results = PricingEngine.applyPricing(new List<PricingEngine.PricingRequest>{ req });
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(true, results[0].success, 'Should succeed');
        
        // Verify order totals
        SecondaryOrder__c updatedOrder = [
            SELECT GrossAmount__c, NetAmount__c, TaxAmount__c
            FROM SecondaryOrder__c
            WHERE Id = :order.Id
        ];
        System.assertNotEquals(null, updatedOrder.GrossAmount__c, 'Gross amount should be set');
        System.assertNotEquals(null, updatedOrder.NetAmount__c, 'Net amount should be set');
        System.assertNotEquals(null, updatedOrder.TaxAmount__c, 'Tax amount should be set');
        
        // Verify line amounts
        List<SecondaryOrderLine__c> updatedLines = [
            SELECT UnitPrice__c, NetLineAmount__c, Tax__c
            FROM SecondaryOrderLine__c
            WHERE SecondaryOrder__c = :order.Id
        ];
        for (SecondaryOrderLine__c line : updatedLines) {
            System.assertNotEquals(null, line.UnitPrice__c, 'Unit price should be set');
            System.assertNotEquals(null, line.NetLineAmount__c, 'Net line amount should be set');
        }
    }
    
    @isTest
    static void testApplyPricing_NoLines() {
        SecondaryOrder__c order = [SELECT Id FROM SecondaryOrder__c LIMIT 1];
        
        // Delete lines
        delete [SELECT Id FROM SecondaryOrderLine__c WHERE SecondaryOrder__c = :order.Id];
        
        PricingEngine.PricingRequest req = new PricingEngine.PricingRequest();
        req.orderId = order.Id;
        req.orderLineIds = new List<Id>();
        
        Test.startTest();
        List<PricingEngine.PricingResult> results = PricingEngine.applyPricing(new List<PricingEngine.PricingRequest>{ req });
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(false, results[0].success, 'Should fail');
        System.assert(results[0].errors.size() > 0, 'Should have errors');
    }
    
    @isTest
    static void testNormalizeQuantity() {
        // Note: normalizeQuantity is private, so we test it indirectly through applyPricing
        // This test verifies the quantity normalization works through the full flow
        SecondaryOrder__c order = [SELECT Id FROM SecondaryOrder__c LIMIT 1];
        List<SecondaryOrderLine__c> lines = [
            SELECT Id, QtyDisplay__c, UoM__c FROM SecondaryOrderLine__c WHERE SecondaryOrder__c = :order.Id
        ];
        
        // Update lines with different UoMs
        lines[0].QtyDisplay__c = '2';
        lines[0].UoM__c = 'CS';
        lines[1].QtyDisplay__c = '3';
        lines[1].UoM__c = 'PK';
        update lines;
        
        List<Id> lineIds = new List<Id>();
        for (SecondaryOrderLine__c line : lines) {
            lineIds.add(line.Id);
        }
        
        PricingEngine.PricingRequest req = new PricingEngine.PricingRequest();
        req.orderId = order.Id;
        req.orderLineIds = lineIds;
        
        Test.startTest();
        List<PricingEngine.PricingResult> results = PricingEngine.applyPricing(new List<PricingEngine.PricingRequest>{ req });
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one result');
        System.assertEquals(true, results[0].success, 'Should succeed');
        
        // Verify quantities were normalized
        List<SecondaryOrderLine__c> updatedLines = [
            SELECT QtyBase__c, QtyDisplay__c, UoM__c FROM SecondaryOrderLine__c WHERE SecondaryOrder__c = :order.Id
        ];
        System.assert(updatedLines[0].QtyBase__c > 0, 'QtyBase should be set');
    }
}
