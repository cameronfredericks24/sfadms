/**
 * @description Test class for ImageAIHook
 * @author RCG Team
 * @date 2024
 */
@isTest
private class ImageAIHookTest {
    
    @isTest
    static void testAnalyzeImage_Success() {
        // Create content version
        ContentVersion cv = new ContentVersion(
            Title = 'Test Image',
            PathOnClient = 'test.jpg',
            VersionData = Blob.valueOf('Test Image Data'),
            IsMajorVersion = true
        );
        insert cv;
        
        Test.startTest();
        ImageAIHook.AnalysisResult result = ImageAIHook.analyzeImage(cv.Id);
        Test.stopTest();
        
        System.assertEquals(true, result.success, 'Should succeed');
        System.assert(result.labels.size() > 0, 'Should have labels');
        System.assert(result.osaScore > 0, 'Should have OSA score');
    }
    
    @isTest
    static void testAnalyzeImage_HttpCalloutMock() {
        Test.setMock(HttpCalloutMock.class, new ImageAIHookMock());
        
        ContentVersion cv = new ContentVersion(
            Title = 'Test Image',
            PathOnClient = 'test.jpg',
            VersionData = Blob.valueOf('Test Image Data'),
            IsMajorVersion = true
        );
        insert cv;
        
        Test.startTest();
        ImageAIHook.AnalysisResult result = ImageAIHook.analyzeImage(cv.Id);
        Test.stopTest();
        
        System.assertEquals(true, result.success, 'Should succeed');
    }
    
    /**
     * @description Mock HTTP callout for testing
     */
    private class ImageAIHookMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"labels":["Product","Shelf"],"osaScore":85}');
            res.setStatusCode(200);
            return res;
        }
    }
}
