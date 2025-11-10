/**
 * @description Service class for BeatRoute queries
 */
public with sharing class BeatRouteService {
    
    @AuraEnabled(cacheable=true)
    public static List<BeatRoute__c> getTodayBeatRoutes() {
        return [
            SELECT Id, Name, Date__c, Rep__c, Status__c, PlannedDoors__c
            FROM BeatRoute__c
            WHERE Date__c = TODAY
            ORDER BY CreatedDate ASC
        ];
    }
}
