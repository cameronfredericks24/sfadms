// Demo script: Create GRN and post to inventory ledger
System.debug('Creating GRN...');

// Get distributor and products
List<Account> distributors = [SELECT Id FROM Account WHERE Type = 'Distributor' LIMIT 1];
List<Product2> products = [SELECT Id FROM Product2 WHERE IsActive = true LIMIT 3];

if (distributors.isEmpty() || products.isEmpty()) {
    System.debug('ERROR: Required data not found.');
    return;
}

// Create GRN
GRN__c grn = new GRN__c(
    Posted__c = false
);
insert grn;

// Create batch lots if not exist
List<BatchLot__c> lots = new List<BatchLot__c>();
for (Integer i = 0; i < products.size(); i++) {
    lots.add(new BatchLot__c(
        Name = 'LOT-' + String.valueOf(Date.today().year()) + '-' + (i+1),
        Product__c = products[i].Id,
        LotNo__c = 'LOT-' + System.now().getTime() + '-' + i,
        QtyOnHand__c = 0,
        ExpiryDate__c = Date.today().addDays(180)
    ));
}
insert lots;

// Post GRN to update inventory
for (Integer i = 0; i < products.size(); i++) {
    LedgerService.postMovement(
        distributors[0].Id,
        products[i].Id,
        'StockIn',
        100,
        'GRN',
        grn.Id + ':' + products[i].Id
    );
}

grn.Posted__c = true;
update grn;

System.debug('GRN created and posted: ' + grn.Id);
System.debug('Inventory ledger entries created: ' + products.size());
