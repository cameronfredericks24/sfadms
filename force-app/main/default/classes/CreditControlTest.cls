/**
 * @description Test class for CreditControl
 */
@isTest
private class CreditControlTest {
    
    @testSetup
    static void setup() {
        // Note: RecordType setup may need adjustment based on org configuration
        Account distributor = new Account(
            Name = 'Test Distributor',
            CreditLimit__c = 10000,
            TotalOutstanding__c = 0
        );
        insert distributor;
    }
    
    @isTest
    static void testCheckCreditStatus() {
        Account distributor = [SELECT Id, CreditHold__c FROM Account LIMIT 1];
        distributor.TotalOutstanding__c = 9600; // 96% utilization
        
        Test.startTest();
        CreditControl.checkCreditStatus(distributor.Id);
        Test.stopTest();
        
        Account updated = [SELECT CreditHold__c FROM Account WHERE Id = :distributor.Id];
        System.assertEquals(true, updated.CreditHold__c);
    }
    
    @isTest
    static void testValidateOrderCredit() {
        Account distributor = [SELECT Id FROM Account LIMIT 1];
        distributor.CreditLimit__c = 10000;
        distributor.TotalOutstanding__c = 5000;
        update distributor;
        
        Test.startTest();
        Boolean isValid = CreditControl.validateOrderCredit(distributor.Id, 4000);
        Test.stopTest();
        
        System.assertEquals(true, isValid);
    }
    
    @isTest
    static void testValidateOrderCreditExceedsLimit() {
        Account distributor = [SELECT Id FROM Account LIMIT 1];
        distributor.CreditLimit__c = 10000;
        distributor.TotalOutstanding__c = 8000;
        update distributor;
        
        Test.startTest();
        Boolean isValid = CreditControl.validateOrderCredit(distributor.Id, 3000);
        Test.stopTest();
        
        System.assertEquals(false, isValid); // Would exceed limit
    }
}
