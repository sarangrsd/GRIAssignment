public with sharing class SelectorUtility {
    public static List<SObject> executeQuery(String query, Schema.SObjectType sObjectType) {
        if (!sObjectType.getDescribe().isAccessible()) {
            throw new AuraHandledException('Insufficient privileges to access this object.');
        }
        return Database.query(query);
    }
}