public with sharing class CTHealthHeaderController {
    
    @AuraEnabled
    public static Map<String, Integer> getPersonHealthStatusCount(){
        Map<String, Integer> healthCountMap = new Map<String, Integer>();
        for(AggregateResult result : [SELECT Count(Id) personCount, Health_Status__c FROM Person__c GROUP BY Health_Status__c]){
            String status = (String)result.get('Health_Status__c');
            Integer count = Integer.valueOf(result.get('personCount'));
            healthCountMap.put(status, count);
        }
        return healthCountMap;
    }

    @AuraEnabled
    public static Map<String, Integer> getLocationHealthStatusCount(){
        Map<String, Integer> statusCountMap = new Map<String, Integer>();
        for(AggregateResult result : [SELECT Count(Id) locationCount, Status__c FROM Location__c GROUP BY Status__c]){
            String status = (String)result.get('Status__c');
            Integer count = Integer.valueOf(result.get('locationCount'));
            statusCountMap.put(status, count);
        }
        return statusCountMap;
    }
}