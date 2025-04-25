@isTest
private class ProductSearchServiceTest {
    
    @testsetup
    static void setupData(){
        // Create test data for Product2
        insert new List<Product2>{
            new Product2(Name = 'Product A', StockKeepingUnit = 'PA'),
                new Product2(Name = 'Product B', StockKeepingUnit = 'PB')
                };
        
        //TODO: Use metadataservice to mock metadata records for testing as they can't be created from test class
    }
    
    
    @isTest static void testContinuationSuccess() {
        Object thisContState;
        
        List<String> skus = new List<String>{'SKU001'};
            String region = 'North America';
        
        Test.startTest();
        Continuation cont = ProductSearchController.searchProductAvailabilityAsync(skus, region);
        Test.stopTest();
        
        System.assertNotEquals(null, cont);
        System.assertEquals('handleAsyncResponse', cont.continuationMethod);
        
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody('[{"sku": "SKU001", "warehouse": "WH001", "availability": "In Stock", "status": "Available"},{"sku": "SKU002", "warehouse": "WH002", "availability": "In Stock", "status": "Available"}]');
        
        Test.setContinuationResponse(ProductSearchController.continuationLabel, res);
        
        // Simulate the continuation response
        // After callout finishes, the state will be passed in handleAsyncResponse
        Object contiStateObj = JSON.deserialize(ProductSearchController.continuationStateString, ProductSearchController.StateInfo.class);
        List<Map<String,Object>> processedResponse = (List<Map<String,Object>>) ProductSearchController.handleAsyncResponse(contiStateObj);
        for(Map<String,Object> responseObj : processedResponse){
            if(responseObj.containsKey('SKU001')){
                system.assertEquals(responseObj.get('warehouse'),'WH001');
            }
            else if(responseObj.containsKey('SKU002')){
                system.assertEquals(responseObj.get('warehouse'),'WH002');
            }
        }
    }
    
    @isTest static void testContinuationError() {
        
        List<String> skus = new List<String>{'SKU001'};
            String region = 'North America';
        
        Test.startTest();
        Continuation cont = ProductSearchController.searchProductAvailabilityAsync(skus, region);
        Test.stopTest();
        
        System.assertNotEquals(null, cont);
        
        // Simulate handling the continuation response
        HttpResponse res = new HttpResponse();
        res.setStatusCode(500);
        res.setBody('{"message": "Invalid request."}');
        
        Test.setContinuationResponse(ProductSearchController.continuationLabel, res);
        try {
            Object contiStateObj = JSON.deserialize(ProductSearchController.continuationStateString, ProductSearchController.StateInfo.class);
            ProductSearchController.handleAsyncResponse(contiStateObj);
        } catch (AuraHandledException ex) {
            System.assert(ex.getMessage().contains('Script-thrown exception'));	//Can be more enhanced based on Error log verification etc. TODO
            system.assertEquals(1, [select id from Error_log__c].size());
        }
    }
    
    @isTest
    static void testLoadPicklistValues() {
        
        // Call the method
        Test.startTest();
        ProductSearchController.PicklistWrapper result = ProductSearchController.loadPicklistValues();
        Test.stopTest();
        
        // Validate the results
        System.assertNotEquals(null, result, 'Result should not be null');
        
        // Validate product data
        System.assertEquals('Product A', result.products[0].Name);
        System.assertEquals('PA', result.products[0].StockKeepingUnit);
        
        //TODO: Use metadataservice to mock metadata records for testing as they can't be created from test class
    }
}