/**
 * @description Test class for PricingEngine
 * @group Tests
 */
@IsTest
private class PricingEngineTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test accounts
        Account distributor = new Account(
            Name = 'Test Distributor',
            Type = 'Distributor'
        );
        insert distributor;
        
        Account retailer = new Account(
            Name = 'Test Retailer',
            Type = 'Retailer',
            ParentId = distributor.Id
        );
        insert retailer;
        
        // Create test products
        Product2 product = new Product2(
            Name = 'Test Product',
            ProductCode = 'TEST-001',
            Family = 'Beverages',
            IsActive = true
        );
        insert product;
        
        // Create promotion
        Promotion__c promo = new Promotion__c(
            Name = 'Test Promotion',
            ProgramType__c = 'Volume',
            BudgetAmount__c = 10000,
            StartDate__c = Date.today().addDays(-7),
            EndDate__c = Date.today().addDays(30),
            Active__c = true
        );
        insert promo;
        
        // Create promotion rule
        PromoEligibilityRule__c rule = new PromoEligibilityRule__c(
            Promotion__c = promo.Id,
            RuleJSON__c = '{"type":"volume","minQty":10,"discountPct":5}',
            Stackable__c = false,
            Priority__c = 1
        );
        insert rule;
        
        // Create visit
        Visit__c visit = new Visit__c(
            Retailer__c = retailer.Id,
            Rep__c = UserInfo.getUserId(),
            Status__c = 'InProgress'
        );
        insert visit;
        
        // Create order
        SecondaryOrder__c order = new SecondaryOrder__c(
            Retailer__c = retailer.Id,
            Distributor__c = distributor.Id,
            Visit__c = visit.Id,
            Status__c = 'Draft'
        );
        insert order;
        
        // Create order lines
        SecondaryOrderLine__c line = new SecondaryOrderLine__c(
            SecondaryOrder__c = order.Id,
            Product__c = product.Id,
            QtyBase__c = 15
        );
        insert line;
    }
    
    @IsTest
    static void testApplyPricing_Success() {
        // Get test order
        SecondaryOrder__c order = [SELECT Id FROM SecondaryOrder__c LIMIT 1];
        
        // Create input
        PricingEngine.PricingInput input = new PricingEngine.PricingInput();
        input.orderId = order.Id;
        input.recalculateAll = true;
        
        Test.startTest();
        List<PricingEngine.PricingOutput> outputs = PricingEngine.applyPricing(new List<PricingEngine.PricingInput>{input});
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, outputs.size(), 'Should return one output');
        PricingEngine.PricingOutput output = outputs[0];
        System.assert(output.success, 'Pricing should succeed');
        System.assertNotEquals(null, output.grossAmount, 'Gross amount should be calculated');
        System.assertNotEquals(null, output.netAmount, 'Net amount should be calculated');
        System.assertNotEquals(null, output.taxAmount, 'Tax amount should be calculated');
        
        // Verify order was updated
        SecondaryOrder__c updatedOrder = [
            SELECT GrossAmount__c, NetAmount__c, TaxAmount__c 
            FROM SecondaryOrder__c 
            WHERE Id = :order.Id
        ];
        System.assertNotEquals(null, updatedOrder.GrossAmount__c, 'Order gross amount should be set');
        System.assertNotEquals(null, updatedOrder.NetAmount__c, 'Order net amount should be set');
        System.assertNotEquals(null, updatedOrder.TaxAmount__c, 'Order tax amount should be set');
    }
    
    @IsTest
    static void testApplyPricing_NoLines() {
        // Create order without lines
        Account retailer = [SELECT Id FROM Account WHERE Type = 'Retailer' LIMIT 1];
        Account distributor = [SELECT Id FROM Account WHERE Type = 'Distributor' LIMIT 1];
        
        SecondaryOrder__c emptyOrder = new SecondaryOrder__c(
            Retailer__c = retailer.Id,
            Distributor__c = distributor.Id,
            Status__c = 'Draft'
        );
        insert emptyOrder;
        
        PricingEngine.PricingInput input = new PricingEngine.PricingInput();
        input.orderId = emptyOrder.Id;
        
        Test.startTest();
        List<PricingEngine.PricingOutput> outputs = PricingEngine.applyPricing(new List<PricingEngine.PricingInput>{input});
        Test.stopTest();
        
        // Verify error handling
        System.assertEquals(1, outputs.size(), 'Should return one output');
        System.assertEquals(false, outputs[0].success, 'Should fail for order without lines');
        System.assertNotEquals(null, outputs[0].message, 'Should have error message');
    }
    
    @IsTest
    static void testCalculateLinePrice() {
        // Get test data
        SecondaryOrder__c order = [SELECT Id, Retailer__c, Distributor__c FROM SecondaryOrder__c LIMIT 1];
        SecondaryOrderLine__c line = [SELECT Id, Product__c, QtyBase__c FROM SecondaryOrderLine__c LIMIT 1];
        
        Test.startTest();
        Decimal price = PricingEngine.calculateLinePrice(line, order);
        Test.stopTest();
        
        System.assertNotEquals(null, price, 'Price should be calculated');
        System.assert(price >= 0, 'Price should be non-negative');
    }
    
    @IsTest
    static void testCalculateTax() {
        SecondaryOrder__c order = [SELECT Id FROM SecondaryOrder__c LIMIT 1];
        Decimal netAmount = 100.00;
        
        Test.startTest();
        Decimal taxAmount = PricingEngine.calculateTax(netAmount, order);
        Test.stopTest();
        
        System.assertEquals(10.00, taxAmount, 'Tax should be 10% of net amount');
    }
    
    @IsTest
    static void testBulkPricing() {
        // Test bulk processing
        List<SecondaryOrder__c> orders = [SELECT Id FROM SecondaryOrder__c];
        
        List<PricingEngine.PricingInput> inputs = new List<PricingEngine.PricingInput>();
        for (SecondaryOrder__c order : orders) {
            PricingEngine.PricingInput input = new PricingEngine.PricingInput();
            input.orderId = order.Id;
            inputs.add(input);
        }
        
        Test.startTest();
        List<PricingEngine.PricingOutput> outputs = PricingEngine.applyPricing(inputs);
        Test.stopTest();
        
        System.assertEquals(orders.size(), outputs.size(), 'Should return output for each input');
    }
}
