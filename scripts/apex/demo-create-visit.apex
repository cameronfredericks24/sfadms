// Demo script: Create and complete a visit
System.debug('Creating sample visit...');

// Get a retailer
List<Account> retailers = [SELECT Id, Name, ShippingLatitude, ShippingLongitude 
                           FROM Account WHERE Type = 'Retailer' LIMIT 1];
if (retailers.isEmpty()) {
    System.debug('ERROR: No retailers found. Run data-seed.sh first.');
    return;
}

Account retailer = retailers[0];

// Create visit
Visit__c visit = new Visit__c(
    Retailer__c = retailer.Id,
    Rep__c = UserInfo.getUserId(),
    Status__c = 'InProgress',
    CheckIn__c = Datetime.now(),
    Latitude__c = retailer.ShippingLatitude,
    Longitude__c = retailer.ShippingLongitude
);
insert visit;

// Create activities
List<Activity__c> activities = new List<Activity__c>();
activities.add(new Activity__c(
    Visit__c = visit.Id,
    Type__c = 'OSA',
    ChecklistJSON__c = '{"items":["Coca Cola","Pepsi","Sprite"],"completed":3}'
));
activities.add(new Activity__c(
    Visit__c = visit.Id,
    Type__c = 'PriceCheck',
    ResultJSON__c = '{"products":[{"sku":"SKU-CC-500","price":1.99}]}'
));
insert activities;

// Check out
visit.CheckOut__c = Datetime.now();
visit.Status__c = 'Completed';
visit.ComplianceScore__c = 95;
visit.Summary__c = 'Visit completed successfully. All activities done.';
update visit;

System.debug('Visit created and completed: ' + visit.Id);
System.debug('Activities created: ' + activities.size());
