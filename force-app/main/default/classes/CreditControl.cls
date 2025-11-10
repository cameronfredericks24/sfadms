/**
 * @description Credit control service for distributors
 */
public with sharing class CreditControl {
    
    public static void checkCreditStatus(Id accountId) {
        Account acc = [
            SELECT Id, CreditLimit__c, TotalOutstanding__c, CreditHold__c
            FROM Account
            WHERE Id = :accountId
            AND RecordType.DeveloperName = 'Distributor'
            LIMIT 1
        ];
        
        if (acc.CreditLimit__c == null) {
            return; // No credit limit set
        }
        
        Decimal outstanding = acc.TotalOutstanding__c != null ? acc.TotalOutstanding__c : 0;
        Decimal utilization = acc.CreditLimit__c > 0 ? (outstanding / acc.CreditLimit__c) * 100 : 0;
        
        // Set credit hold if utilization exceeds 95%
        Boolean shouldHold = utilization >= 95;
        
        if (acc.CreditHold__c != shouldHold) {
            acc.CreditHold__c = shouldHold;
            update acc;
        }
    }
    
    public static Boolean validateOrderCredit(Id distributorId, Decimal orderAmount) {
        Account acc = [
            SELECT Id, CreditLimit__c, TotalOutstanding__c, CreditHold__c
            FROM Account
            WHERE Id = :distributorId
            LIMIT 1
        ];
        
        if (acc.CreditHold__c) {
            return false;
        }
        
        if (acc.CreditLimit__c == null) {
            return true; // No limit
        }
        
        Decimal outstanding = acc.TotalOutstanding__c != null ? acc.TotalOutstanding__c : 0;
        return (outstanding + orderAmount) <= acc.CreditLimit__c;
    }
}
