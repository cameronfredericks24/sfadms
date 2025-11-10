/**
 * @description Test class for Util
 */
@isTest
private class UtilTest {
    
    @isTest
    static void testRoundCurrency() {
        Test.startTest();
        Decimal result = Util.roundCurrency(123.456789);
        Test.stopTest();
        
        System.assertEquals(123.46, result);
    }
    
    @isTest
    static void testRoundQuantity() {
        Test.startTest();
        Decimal result = Util.roundQuantity(123.456789);
        Test.stopTest();
        
        System.assertEquals(123.457, result);
    }
    
    @isTest
    static void testParseJSON() {
        String jsonString = '{"key":"value","number":123}';
        
        Test.startTest();
        Map<String, Object> result = Util.parseJSON(jsonString);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assertEquals('value', result.get('key'));
    }
    
    @isTest
    static void testSerializeJSON() {
        Map<String, Object> data = new Map<String, Object>{
            'key' => 'value',
            'number' => 123
        };
        
        Test.startTest();
        String result = Util.serializeJSON(data);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assert(result.contains('key'));
    }
    
    @isTest
    static void testCalculateDistance() {
        // Test distance between two points (approximately)
        Decimal lat1 = 37.7749;
        Decimal lon1 = -122.4194;
        Decimal lat2 = 37.7849;
        Decimal lon2 = -122.4094;
        
        Test.startTest();
        Decimal distance = Util.calculateDistance(lat1, lon1, lat2, lon2);
        Test.stopTest();
        
        System.assertNotEquals(null, distance);
        System.assert(distance > 0);
    }
}
