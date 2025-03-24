public with sharing class CTHealthHeaderController {
    
    @AuraEnabled
    public static Map<String, Integer> getHealthStatusCount() {
        Map<String, Integer> statusCountMap = new Map<String, Integer>();
        
        // Person health status counts
        for (AggregateResult ar : [SELECT Health_Status__c, COUNT(Id) countRecords 
                                  FROM Person__c 
                                  WHERE Health_Status__c != null 
                                  GROUP BY Health_Status__c]) {
            String status = (String)ar.get('Health_Status__c');
            Integer count = (Integer)ar.get('countRecords');
            statusCountMap.put(status, count);
        }
        
        // Ensure all statuses have a value
        for (String status : new List<String>{'Green', 'Yellow', 'Orange', 'Red'}) {
            if (!statusCountMap.containsKey(status)) {
                statusCountMap.put(status, 0);
            }
        }
        
        return statusCountMap;
    }
    
    @AuraEnabled
    public static Map<String, Integer> getLocationHealthStatusCount() {
        Map<String, Integer> statusCountMap = new Map<String, Integer>();
        
        // Location status counts
        for (AggregateResult ar : [SELECT Status__c, COUNT(Id) countRecords 
                                  FROM Location__c 
                                  WHERE Status__c != null 
                                  GROUP BY Status__c]) {
            String status = (String)ar.get('Status__c');
            Integer count = (Integer)ar.get('countRecords');
            statusCountMap.put(status, count);
        }
        
        // Ensure all statuses have a value
        for (String status : new List<String>{'Green', 'Yellow', 'Orange', 'Red'}) {
            if (!statusCountMap.containsKey(status)) {
                statusCountMap.put(status, 0);
            }
        }
        
        return statusCountMap;
    }
    
    @AuraEnabled
    public static Id createPerson(Person__c personRecord) {
        try {
            System.debug('Creating person with status: ' + personRecord.Health_Status__c);
            insert personRecord;
            return personRecord.Id;
        } catch (Exception e) {
            System.debug('Error creating person: ' + e.getMessage());
            throw new AuraHandledException('Error creating person record: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Id createLocation(Location__c locationRecord) {
        try {
            insert locationRecord;
            return locationRecord.Id;
        } catch (Exception e) {
            throw new AuraHandledException('Error creating location record: ' + e.getMessage());
        }
    }
}