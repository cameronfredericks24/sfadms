/**
 * @description Test class for FEFOAllocator
 */
@isTest
private class FEFOAllocatorTest {
    
    @testSetup
    static void setup() {
        Product2 product = new Product2(
            Name = 'Test Product',
            IsActive = true,
            ProductCode = 'TEST-001'
        );
        insert product;
        
        // Create batch lots with different expiry dates
        List<BatchLot__c> lots = new List<BatchLot__c>();
        for (Integer i = 0; i < 3; i++) {
            lots.add(new BatchLot__c(
                Product__c = product.Id,
                LotNo__c = 'LOT-' + i,
                ExpiryDate__c = Date.today().addDays(30 + (i * 10)),
                QtyOnHand__c = 100,
                Status__c = 'Available'
            ));
        }
        insert lots;
    }
    
    @isTest
    static void testAllocateBatchLot() {
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        Date thresholdDate = Date.today().addDays(20);
        
        Test.startTest();
        BatchLot__c allocated = FEFOAllocator.allocateBatchLot(product.Id, 50, thresholdDate);
        Test.stopTest();
        
        System.assertNotEquals(null, allocated);
        System.assertEquals('Available', allocated.Status__c);
    }
    
    @isTest
    static void testAllocateBatchLotNoAvailable() {
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        Date thresholdDate = Date.today().addDays(100); // Future date - no lots available
        
        Test.startTest();
        try {
            FEFOAllocator.allocateBatchLot(product.Id, 50, thresholdDate);
            System.assert(false, 'Expected exception');
        } catch (FEFOAllocator.FEFOException e) {
            System.assert(e.getMessage().contains('No available batch lots'));
        }
        Test.stopTest();
    }
    
    @isTest
    static void testAllocateMultipleLots() {
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        Date thresholdDate = Date.today().addDays(20);
        
        Test.startTest();
        List<BatchLot__c> allocated = FEFOAllocator.allocateMultipleLots(product.Id, 250, thresholdDate);
        Test.stopTest();
        
        System.assert(allocated.size() > 0);
    }
}
