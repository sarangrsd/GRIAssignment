public with sharing class RegionSelector {
    public static List<Regions__mdt> getAllRegions() {
        return [SELECT Region_Name__c FROM Regions__mdt];
    }
}