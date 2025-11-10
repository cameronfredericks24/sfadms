// Demo script: Create and process a claim
System.debug('Creating claim...');

// Get accounts
List<Account> retailers = [SELECT Id FROM Account WHERE Type = 'Retailer' LIMIT 1];
List<Account> distributors = [SELECT Id FROM Account WHERE Type = 'Distributor' LIMIT 1];

if (retailers.isEmpty() || distributors.isEmpty()) {
    System.debug('ERROR: Required data not found.');
    return;
}

// Create claim
Claim__c claim = new Claim__c(
    Type__c = 'Expiry',
    Amount__c = 150.00,
    Status__c = 'Submitted'
);
insert claim;

// Auto-approve (in real scenario, would go through approval process)
claim.Status__c = 'Approved';
update claim;

// Settle
claim.Status__c = 'Settled';
update claim;

System.debug('Claim created and settled: ' + claim.Id);
System.debug('Type: Expiry, Amount: $150.00');
System.debug('Status: Settled');
