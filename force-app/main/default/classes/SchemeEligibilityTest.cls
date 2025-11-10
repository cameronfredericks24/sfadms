/**
 * @description Test class for SchemeEligibility
 */
@isTest
private class SchemeEligibilityTest {
    
    @testSetup
    static void setup() {
        Product2 product = new Product2(
            Name = 'Test Product',
            IsActive = true,
            ProductCode = 'TEST-001'
        );
        insert product;
        
        Promotion__c promo = new Promotion__c(
            ProgramType__c = 'Volume',
            BudgetAmount__c = 10000,
            StartDate__c = Date.today().addDays(-10),
            EndDate__c = Date.today().addDays(10),
            Active__c = true
        );
        insert promo;
        
        PromoEligibilityRule__c rule = new PromoEligibilityRule__c(
            Promotion__c = promo.Id,
            RuleJSON__c = '{"type":"slab","minQty":5,"maxQty":100}',
            Stackable__c = false,
            Priority__c = 1
        );
        insert rule;
    }
    
    @isTest
    static void testEvaluatePromotions() {
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        Promotion__c promo = [SELECT Id FROM Promotion__c LIMIT 1];
        PromoEligibilityRule__c rule = [SELECT Id, Promotion__c, RuleJSON__c FROM PromoEligibilityRule__c LIMIT 1];
        
        SecondaryOrderLine__c line = new SecondaryOrderLine__c(
            Product__c = product.Id,
            QtyBase__c = 10
        );
        
        Map<Id, List<PromoEligibilityRule__c>> promoRulesMap = new Map<Id, List<PromoEligibilityRule__c>>();
        promoRulesMap.put(promo.Id, new List<PromoEligibilityRule__c>{ rule });
        
        Test.startTest();
        List<Promotion__c> applicablePromos = SchemeEligibility.evaluatePromotions(
            line,
            new List<Promotion__c>{ promo },
            promoRulesMap
        );
        Test.stopTest();
        
        System.assertEquals(1, applicablePromos.size());
    }
}
