// Demo script: Create secondary order with promotions
System.debug('Creating secondary order...');

// Get accounts
List<Account> retailers = [SELECT Id FROM Account WHERE Type = 'Retailer' LIMIT 1];
List<Account> distributors = [SELECT Id FROM Account WHERE Type = 'Distributor' LIMIT 1];
List<Product2> products = [SELECT Id FROM Product2 WHERE IsActive = true LIMIT 5];

if (retailers.isEmpty() || distributors.isEmpty() || products.isEmpty()) {
    System.debug('ERROR: Required data not found. Run data-seed.sh first.');
    return;
}

// Create order
SecondaryOrder__c order = new SecondaryOrder__c(
    Retailer__c = retailers[0].Id,
    Distributor__c = distributors[0].Id,
    Status__c = 'Draft',
    RequestedDeliveryDate__c = Date.today().addDays(2)
);
insert order;

// Create order lines
List<SecondaryOrderLine__c> lines = new List<SecondaryOrderLine__c>();
for (Integer i = 0; i < products.size(); i++) {
    lines.add(new SecondaryOrderLine__c(
        SecondaryOrder__c = order.Id,
        Product__c = products[i].Id,
        QtyBase__c = 10 + (i * 5),
        UnitPrice__c = 10.00
    ));
}
insert lines;

// Confirm order to trigger pricing
order.Status__c = 'Confirmed';
update order;

System.debug('Secondary Order created: ' + order.Id);
System.debug('Order Lines: ' + lines.size());
System.debug('Status: Confirmed (pricing will be calculated)');
