/**
 * @description Checks distributor credit status and sets hold flags on Account
 * @author RCG Team
 * @date 2024
 */
public with sharing class CreditControl {
    
    /**
     * @description Checks credit status for distributor
     * @param distributorId Distributor account ID
     * @return Credit check result
     */
    public static CreditResult checkCredit(Id distributorId) {
        CreditResult result = new CreditResult();
        result.allowed = true;
        result.reason = '';
        
        Account distributor = [
            SELECT Id, CreditLimit__c, CreditHold__c, OutstandingBalance__c
            FROM Account
            WHERE Id = :distributorId
            AND Type = 'Distributor'
            LIMIT 1
        ];
        
        if (distributor == null) {
            result.allowed = false;
            result.reason = 'Distributor not found';
            return result;
        }
        
        // Check if already on hold
        if (distributor.CreditHold__c == true) {
            result.allowed = false;
            result.reason = 'Account is on credit hold';
            return result;
        }
        
        // Check credit limit
        Decimal creditLimit = distributor.CreditLimit__c != null ? distributor.CreditLimit__c : 0;
        Decimal outstandingBalance = distributor.OutstandingBalance__c != null ? distributor.OutstandingBalance__c : 0;
        
        if (outstandingBalance >= creditLimit) {
            result.allowed = false;
            result.reason = 'Credit limit exceeded';
            
            // Set credit hold
            distributor.CreditHold__c = true;
            update distributor;
        }
        
        return result;
    }
    
    /**
     * @description Credit check result
     */
    public class CreditResult {
        public Boolean allowed;
        public String reason;
    }
}
