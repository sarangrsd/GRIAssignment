// --- Apex Controller ---
public with sharing class ProductSearchController {
    // Test variable used for holding a reference to the Continuation Request
    @TestVisible
    private static String continuationLabel;
    // Test variable used for holding the value of the Continuation.state attribute
    @TestVisible
    private static String continuationStateString;
    
    //Method to fetch product SKU list and regions
    @AuraEnabled(cacheable=true)
    public static PicklistWrapper loadPicklistValues() {
        try{
            ProductSelector psInstance = new ProductSelector(true, true, true,new Set<String>{'Id','Name','StockKeepingUnit'});
            List<Product2> products = psInstance.getAllProducts();
            List<Regions__mdt> regions = RegionSelector.getAllRegions();
            return new PicklistWrapper(products, regions);   
        }
        catch (Exception ex) {
            throw new AuraHandledException('Error fetching data: ' + ex.getMessage());
        }
    }
    
    
    //Called from LWC realTimeInventorySearch when users selects products and regions to search.
    @AuraEnabled(continuation=true)
    public static Continuation searchProductAvailabilityAsync(List<String> productSKUs, String region) {
        Continuation cont = new Continuation(120);
        cont.continuationMethod = 'handleAsyncResponse';
        
        try {
            HttpRequest req = ServiceUtilities.makeHTTPCallout('GET', 'https://dummyjson.com/c/e253-d4e3-4ba7-bb50', JSON.serialize(new Map<String, Object>{
                'productSKUs' => productSKUs,
                    'region' => region
                    }));//TODO: credentials storage with named credentials/external services.
            continuationLabel = cont.addHttpRequest(req)	;// Store the reference to the HttRequest and make it accessible for a test-context
            // Store data to be sent to the callback function
            Object continuationState = new StateInfo(productSKUs,region,continuationLabel);
            continuationStateString =  JSON.serialize(continuationState);
            cont.state = continuationState;
        } catch (Exception ex) {
            Error_Log__c log = new Error_Log__c(Location__c='ProductSearchController.searchProductAvailabilityAsync',
                                                Error_Message__c=ex.getMessage(),
                                                Stack_Trace__c=ex.getStackTraceString(),
                                                Exception_Type__c=ex.getTypeName());
            insert log;
            throw new AuraHandledException('Error preparing callout: ' + ex.getMessage());
        }
        
        return cont;
    }
    
    //Callback function invoked after contiuation is returned to process the response and show search results to LWC.
    @AuraEnabled
    public static Object handleAsyncResponse(Object state) {
        StateInfo stateMap = (StateInfo) state;
        system.debug('State: ' + JSON.serialize(stateMap));
        HttpResponse response = Continuation.getResponse(stateMap.continuationLabel);
        if (response.getStatusCode() == 200) {
            try {
                List<Object> rawList = (List<Object>) JSON.deserializeUntyped(response.getBody());
                List<Map<String, Object>> formattedList = new List<Map<String, Object>>();
                for (Object item : rawList) {
                    if (item instanceof Map<String, Object>) {
                        formattedList.add((Map<String, Object>)item);
                    }
                }
                return formattedList;
            } catch (Exception parseEx) {
                Error_Log__c log = new Error_Log__c(Location__c='ProductSearchController.handleAsyncResponse', Error_Message__c=parseEx.getMessage(), Stack_Trace__c=parseEx.getStackTraceString(), Exception_Type__c=parseEx.getTypeName());
                insert log;
                throw new AuraHandledException('Error parsing response: ' + parseEx.getMessage());
            }
        } else {
            Error_Log__c log = new Error_Log__c(Location__c='ProductSearchController.handleAsyncResponse', Error_Message__c=response.getBody(), Stack_Trace__c='HTTP Status: ' + response.getStatusCode(), Exception_Type__c='CalloutException');
            insert log;
            throw new AuraHandledException('Callout failed: ' + response.getBody());
        }
    }
    
    // Inner class to hold state info
    public class StateInfo {
        List<String> productSKUs;
        String region;
        String continuationLabel;
        
        StateInfo(List<String> productSKUs, String region, String continuationLabel){
            this.productSKUs = productSKUs; 
            this.region = region;
            this.continuationLabel = continuationLabel;
        }
    }
    
    public class PicklistWrapper {
        @AuraEnabled public List<Product2> products;
        @AuraEnabled public List<Regions__mdt> regions;
        
        public PicklistWrapper(List<Product2> products, List<Regions__mdt> regions) {
            this.products = products;
            this.regions = regions;
        }
    }
    
}