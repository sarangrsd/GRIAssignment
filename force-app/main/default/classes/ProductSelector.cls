public with sharing class ProductSelector {
    public static List<Product2> getAllProducts() {
        String query = 'SELECT Id, Name, StockKeepingUnit FROM Product2';
        return (List<Product2>) SelectorUtility.executeQuery(query, Product2.SObjectType);
    }
}