/**
 * @description Test class for FEFOAllocator
 * @author RCG Team
 * @date 2024
 */
@isTest
private class FEFOAllocatorTest {
    
    @testSetup
    static void setupTestData() {
        Product2 product = new Product2(Name = 'Test Product', ProductCode = 'PROD-001', IsActive = true);
        insert product;
        
        // Create batch lots with different expiry dates
        List<BatchLot__c> lots = new List<BatchLot__c>();
        lots.add(new BatchLot__c(
            Product__c = product.Id,
            LotNo__c = 'LOT-001',
            ExpiryDate__c = Date.today().addDays(60),
            QtyOnHand__c = 100,
            Status__c = 'Available'
        ));
        lots.add(new BatchLot__c(
            Product__c = product.Id,
            LotNo__c = 'LOT-002',
            ExpiryDate__c = Date.today().addDays(90),
            QtyOnHand__c = 200,
            Status__c = 'Available'
        ));
        insert lots;
    }
    
    @isTest
    static void testAllocateBatchLot_Success() {
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        SecondaryOrderLine__c orderLine = new SecondaryOrderLine__c(Product__c = product.Id);
        
        Test.startTest();
        Id allocatedLotId = FEFOAllocator.allocateBatchLot(orderLine, product.Id, 50);
        Test.stopTest();
        
        System.assertNotEquals(null, allocatedLotId, 'Should allocate batch lot');
        System.assertEquals(allocatedLotId, orderLine.BatchLot__c, 'Order line should have batch lot');
    }
    
    @isTest
    static void testAllocateBatchLot_InsufficientQuantity() {
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        SecondaryOrderLine__c orderLine = new SecondaryOrderLine__c(Product__c = product.Id);
        
        Test.startTest();
        try {
            FEFOAllocator.allocateBatchLot(orderLine, product.Id, 500);
            System.assert(false, 'Should throw exception');
        } catch (FEFOAllocator.FEFOException e) {
            System.assert(e.getMessage().contains('Insufficient quantity'), 'Should throw insufficient quantity error');
        }
        Test.stopTest();
    }
}
