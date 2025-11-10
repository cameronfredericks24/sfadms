/**
 * @description Test class for SchemeEligibility
 * @author RCG Team
 * @date 2024
 */
@isTest
private class SchemeEligibilityTest {
    
    @testSetup
    static void setupTestData() {
        Account retailer = new Account(Name = 'Test Retailer', Type = 'Retailer');
        insert retailer;
        
        Product2 product = new Product2(Name = 'Test Product', ProductCode = 'PROD-001', IsActive = true);
        insert product;
        
        SecondaryOrder__c order = new SecondaryOrder__c(
            Retailer__c = retailer.Id,
            NetAmount__c = 1000
        );
        insert order;
        
        SecondaryOrderLine__c line = new SecondaryOrderLine__c(
            SecondaryOrder__c = order.Id,
            Product__c = product.Id,
            QtyBase__c = 10,
            UnitPrice__c = 100
        );
        insert line;
    }
    
    @isTest
    static void testEvaluateSlab_Success() {
        SecondaryOrder__c order = [SELECT Id, NetAmount__c FROM SecondaryOrder__c LIMIT 1];
        List<SecondaryOrderLine__c> lines = [SELECT Id FROM SecondaryOrderLine__c WHERE SecondaryOrder__c = :order.Id];
        
        String ruleJSON = '{"type":"SLAB","slabs":[{"min":500,"max":2000,"discountType":"PERCENTAGE","discountValue":10}]}';
        
        Test.startTest();
        SchemeEligibility.EligibilityResult result = SchemeEligibility.evaluate(ruleJSON, order, lines);
        Test.stopTest();
        
        System.assertEquals(true, result.eligible, 'Should be eligible');
        System.assert(result.discountAmount > 0, 'Should have discount');
    }
    
    @isTest
    static void testEvaluateBundle_Success() {
        SecondaryOrder__c order = [SELECT Id FROM SecondaryOrder__c LIMIT 1];
        List<SecondaryOrderLine__c> lines = [SELECT Id, Product__c FROM SecondaryOrderLine__c WHERE SecondaryOrder__c = :order.Id];
        
        String productId = lines[0].Product__c;
        String ruleJSON = '{"type":"BUNDLE","requiredProducts":["' + productId + '"],"discountAmount":50}';
        
        Test.startTest();
        SchemeEligibility.EligibilityResult result = SchemeEligibility.evaluate(ruleJSON, order, lines);
        Test.stopTest();
        
        System.assertEquals(true, result.eligible, 'Should be eligible');
        System.assertEquals(50, result.discountAmount, 'Should have discount amount');
    }
    
    @isTest
    static void testEvaluateBuyXGetY_Success() {
        SecondaryOrder__c order = [SELECT Id FROM SecondaryOrder__c LIMIT 1];
        List<SecondaryOrderLine__c> lines = [SELECT Id, Product__c, QtyBase__c, UnitPrice__c FROM SecondaryOrderLine__c WHERE SecondaryOrder__c = :order.Id];
        
        String productId = lines[0].Product__c;
        String ruleJSON = '{"type":"BUYXGETY","qualifyingProductId":"' + productId + '","buyQuantity":5,"getQuantity":1}';
        
        Test.startTest();
        SchemeEligibility.EligibilityResult result = SchemeEligibility.evaluate(ruleJSON, order, lines);
        Test.stopTest();
        
        System.assertEquals(true, result.eligible, 'Should be eligible');
        System.assert(result.discountAmount > 0, 'Should have discount');
    }
}
