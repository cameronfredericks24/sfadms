/**
 * @description Test class for SecondaryOrderLineTriggerHandler
 */
@isTest
private class SecondaryOrderLineTriggerHandlerTest {
    
    @testSetup
    static void setup() {
        Account retailer = new Account(Name = 'Test Retailer');
        Account distributor = new Account(Name = 'Test Distributor');
        insert new List<Account>{ retailer, distributor };
        
        Product2 product = new Product2(Name = 'Test Product', IsActive = true);
        insert product;
        
        SecondaryOrder__c order = new SecondaryOrder__c(
            Retailer__c = retailer.Id,
            Distributor__c = distributor.Id
        );
        insert order;
    }
    
    @isTest
    static void testNormalizeQuantities() {
        SecondaryOrder__c order = [SELECT Id FROM SecondaryOrder__c LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        
        Test.startTest();
        SecondaryOrderLine__c line = new SecondaryOrderLine__c(
            SecondaryOrder__c = order.Id,
            Product__c = product.Id,
            QtyDisplay__c = '10',
            UoM__c = 'EA'
        );
        insert line;
        Test.stopTest();
        
        line = [SELECT QtyBase__c, UoM__c FROM SecondaryOrderLine__c WHERE Id = :line.Id];
        System.assertEquals(10, line.QtyBase__c);
        System.assertEquals('EA', line.UoM__c);
    }
}
