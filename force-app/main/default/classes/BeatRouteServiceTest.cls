/**
 * @description Test class for BeatRouteService
 */
@isTest
private class BeatRouteServiceTest {
    
    @testSetup
    static void setup() {
        BeatPlan__c plan = new BeatPlan__c(
            Month__c = Date.today().toStartOfMonth(),
            Status__c = 'Published'
        );
        insert plan;
        
        BeatRoute__c route = new BeatRoute__c(
            BeatPlan__c = plan.Id,
            Date__c = Date.today(),
            Status__c = 'Planned'
        );
        insert route;
    }
    
    @isTest
    static void testGetTodayBeatRoutes() {
        Test.startTest();
        List<BeatRoute__c> routes = BeatRouteService.getTodayBeatRoutes();
        Test.stopTest();
        
        System.assertNotEquals(null, routes);
        System.assert(routes.size() > 0);
    }
}
