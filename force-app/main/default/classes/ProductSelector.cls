public with sharing class ProductSelector extends Selector{
        
    public ProductSelector(Set<String> queryFieldsString) {
        super(Schema.Product2.SObjectType, queryFieldsString);
    }

    public ProductSelector(Boolean enforceCRUD, Boolean enforceFLS, Boolean enforceShr, Set<String> queryFieldsString) {
        super(Schema.Product2.SObjectType, enforceCRUD, enforceFLS, enforceShr, queryFieldsString);
    }
    
    public List<Product2> getAllProducts() {
        return (List<Product2>) SelectorUtility.executeQuery(getBaseQuery(), true,true,true,true,AccessType.READABLE);
    }
}