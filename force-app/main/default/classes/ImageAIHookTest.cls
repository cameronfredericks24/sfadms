/**
 * @description Test class for ImageAIHook
 */
@isTest
private class ImageAIHookTest {
    
    @testSetup
    static void setup() {
        Account retailer = new Account(Name = 'Test Retailer');
        insert retailer;
        
        Visit__c visit = new Visit__c(
            Retailer__c = retailer.Id,
            Status__c = 'InProgress'
        );
        insert visit;
    }
    
    @isTest
    static void testAnalyzeImage() {
        // Create mock ContentVersion
        ContentVersion cv = new ContentVersion(
            Title = 'Test Image',
            PathOnClient = 'test.jpg',
            VersionData = Blob.valueOf('Test Image Data')
        );
        insert cv;
        
        Test.startTest();
        ImageAIHook.ImageAnalysisResult result = ImageAIHook.analyzeImage(cv.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assertNotEquals(null, result.labels);
        System.assert(result.confidence > 0);
    }
    
    @isTest
    static void testAnalyzeImageAsync() {
        Visit__c visit = [SELECT Id FROM Visit__c LIMIT 1];
        ContentVersion cv = new ContentVersion(
            Title = 'Test Image',
            PathOnClient = 'test.jpg',
            VersionData = Blob.valueOf('Test Image Data')
        );
        insert cv;
        
        Test.startTest();
        ImageAIHook.analyzeImageAsync(cv.Id, visit.Id);
        Test.stopTest();
        
        // Verify PhotoEvidence created (async)
        Test.getEventBus().deliver();
        
        List<PhotoEvidence__c> evidences = [
            SELECT Id FROM PhotoEvidence__c WHERE Visit__c = :visit.Id
        ];
        System.assertEquals(1, evidences.size());
    }
}
