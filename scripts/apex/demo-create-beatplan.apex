// Demo script: Create Beat Plan for today
System.debug('Creating Beat Plan for today...');

BeatPlan__c plan = new BeatPlan__c(
    Month__c = Date.today(),
    Status__c = 'Published'
);
insert plan;

System.debug('Beat Plan created: ' + plan.Id);
System.debug('Status: Published');
