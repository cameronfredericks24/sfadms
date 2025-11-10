/**
 * @description Test class for GRNLineTriggerHandler
 */
@isTest
private class GRNLineTriggerHandlerTest {
    
    @testSetup
    static void setup() {
        Account distributor = new Account(Name = 'Test Distributor');
        insert distributor;
        
        Product2 product = new Product2(Name = 'Test Product', IsActive = true);
        insert product;
        
        PrimaryOrder__c primaryOrder = new PrimaryOrder__c(Distributor__c = distributor.Id);
        insert primaryOrder;
        
        GRN__c grn = new GRN__c(PrimaryOrder__c = primaryOrder.Id);
        insert grn;
    }
    
    @isTest
    static void testCreateBatchLot() {
        GRN__c grn = [SELECT Id FROM GRN__c LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        
        Test.startTest();
        GRNLine__c line = new GRNLine__c(
            GRN__c = grn.Id,
            Product__c = product.Id,
            ReceivedQty__c = 100,
            AcceptedQty__c = 100
        );
        insert line;
        Test.stopTest();
        
        List<BatchLot__c> lots = [SELECT Id FROM BatchLot__c];
        System.assert(lots.size() > 0);
    }
}
