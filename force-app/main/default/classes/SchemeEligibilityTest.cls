/**
 * @description Test class for SchemeEligibility
 * @group Tests
 */
@IsTest
private class SchemeEligibilityTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test accounts
        Account distributor = new Account(Name = 'Test Distributor', Type = 'Distributor');
        insert distributor;
        
        Account retailer = new Account(Name = 'Test Retailer', Type = 'Retailer');
        insert retailer;
        
        // Create products
        Product2 product = new Product2(Name = 'Test Product', ProductCode = 'TEST-001', IsActive = true);
        insert product;
        
        // Create promotion
        Promotion__c promo = new Promotion__c(
            Name = 'Volume Discount',
            ProgramType__c = 'Volume',
            StartDate__c = Date.today(),
            EndDate__c = Date.today().addDays(30),
            Active__c = true
        );
        insert promo;
        
        // Create rule
        PromoEligibilityRule__c rule = new PromoEligibilityRule__c(
            Promotion__c = promo.Id,
            RuleJSON__c = '{"type":"volume","minQty":10,"discountPct":5}',
            Stackable__c = false,
            Priority__c = 1
        );
        insert rule;
        
        // Create order
        SecondaryOrder__c order = new SecondaryOrder__c(
            Retailer__c = retailer.Id,
            Distributor__c = distributor.Id,
            Status__c = 'Draft'
        );
        insert order;
        
        // Create order lines
        SecondaryOrderLine__c line = new SecondaryOrderLine__c(
            SecondaryOrder__c = order.Id,
            Product__c = product.Id,
            QtyBase__c = 15,
            UnitPrice__c = 100,
            NetLineAmount__c = 1500
        );
        insert line;
    }
    
    @IsTest
    static void testEvaluateVolumeRule_Eligible() {
        SecondaryOrder__c order = [SELECT Id, Retailer__c, Distributor__c FROM SecondaryOrder__c LIMIT 1];
        List<SecondaryOrderLine__c> lines = [SELECT Id, Product__c, QtyBase__c, NetLineAmount__c FROM SecondaryOrderLine__c];
        Promotion__c promo = [SELECT Id, Name FROM Promotion__c LIMIT 1];
        PromoEligibilityRule__c rule = [SELECT Id, RuleJSON__c FROM PromoEligibilityRule__c LIMIT 1];
        
        Test.startTest();
        AppliedPromotion__c applied = SchemeEligibility.evaluateRule(order, lines, promo, rule);
        Test.stopTest();
        
        System.assertNotEquals(null, applied, 'Should apply promotion for eligible order');
        System.assertEquals(75.00, applied.Value__c, 'Discount should be 5% of 1500');
        System.assertEquals(order.Id, applied.SecondaryOrder__c, 'Should link to order');
    }
    
    @IsTest
    static void testEvaluateVolumeRule_NotEligible() {
        SecondaryOrder__c order = [SELECT Id FROM SecondaryOrder__c LIMIT 1];
        List<SecondaryOrderLine__c> lines = [SELECT Id, Product__c, QtyBase__c, NetLineAmount__c FROM SecondaryOrderLine__c];
        
        // Update line to be below threshold
        lines[0].QtyBase__c = 5;
        update lines;
        
        Promotion__c promo = [SELECT Id FROM Promotion__c LIMIT 1];
        PromoEligibilityRule__c rule = [SELECT Id, RuleJSON__c FROM PromoEligibilityRule__c LIMIT 1];
        
        Test.startTest();
        AppliedPromotion__c applied = SchemeEligibility.evaluateRule(order, lines, promo, rule);
        Test.stopTest();
        
        System.assertEquals(null, applied, 'Should not apply promotion for ineligible order');
    }
    
    @IsTest
    static void testEvaluateRule_InvalidJSON() {
        SecondaryOrder__c order = [SELECT Id FROM SecondaryOrder__c LIMIT 1];
        List<SecondaryOrderLine__c> lines = [SELECT Id, QtyBase__c, NetLineAmount__c FROM SecondaryOrderLine__c];
        Promotion__c promo = [SELECT Id FROM Promotion__c LIMIT 1];
        PromoEligibilityRule__c rule = [SELECT Id FROM PromoEligibilityRule__c LIMIT 1];
        
        rule.RuleJSON__c = 'invalid json';
        update rule;
        
        Test.startTest();
        AppliedPromotion__c applied = SchemeEligibility.evaluateRule(order, lines, promo, rule);
        Test.stopTest();
        
        System.assertEquals(null, applied, 'Should handle invalid JSON gracefully');
    }
}
