/**
 * @description Test class for CreditControl
 * @author RCG Team
 * @date 2024
 */
@isTest
private class CreditControlTest {
    
    @testSetup
    static void setupTestData() {
        Account distributor = new Account(
            Name = 'Test Distributor',
            Type = 'Distributor',
            CreditLimit__c = 10000,
            OutstandingBalance__c = 5000,
            CreditHold__c = false
        );
        insert distributor;
    }
    
    @isTest
    static void testCheckCredit_Allowed() {
        Account distributor = [SELECT Id FROM Account WHERE Type = 'Distributor' LIMIT 1];
        
        Test.startTest();
        CreditControl.CreditResult result = CreditControl.checkCredit(distributor.Id);
        Test.stopTest();
        
        System.assertEquals(true, result.allowed, 'Should be allowed');
    }
    
    @isTest
    static void testCheckCredit_Exceeded() {
        Account distributor = [
            SELECT Id, CreditLimit__c, OutstandingBalance__c
            FROM Account
            WHERE Type = 'Distributor'
            LIMIT 1
        ];
        distributor.OutstandingBalance__c = 15000;
        update distributor;
        
        Test.startTest();
        CreditControl.CreditResult result = CreditControl.checkCredit(distributor.Id);
        Test.stopTest();
        
        System.assertEquals(false, result.allowed, 'Should not be allowed');
        System.assert(result.reason.contains('Credit limit'), 'Should have credit limit reason');
        
        Account updated = [SELECT CreditHold__c FROM Account WHERE Id = :distributor.Id];
        System.assertEquals(true, updated.CreditHold__c, 'Should set credit hold');
    }
}
