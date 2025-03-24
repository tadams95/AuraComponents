public with sharing class CTHealthHeaderController {
    
    @AuraEnabled
    public static Map<String, Integer> getPersonHealthStatusCount() {
        Map<String, Integer> healthStatusCountMap = new Map<String, Integer>();
        
        // Query to count people by health status
        for(AggregateResult ar : [
            SELECT Health_Status__c, COUNT(Id) countOfPeople
            FROM Person__c
            GROUP BY Health_Status__c
        ]) {
            String status = (String)ar.get('Health_Status__c');
            Integer statusCount = (Integer)ar.get('countOfPeople');
            healthStatusCountMap.put(status, statusCount);
        }
        
        // Ensure all status values are represented, even if count is 0
        for(String status : new List<String>{'Green', 'Yellow', 'Orange', 'Red'}) {
            if(!healthStatusCountMap.containsKey(status)) {
                healthStatusCountMap.put(status, 0);
            }
        }
        
        return healthStatusCountMap;
    }
    
    @AuraEnabled
    public static Map<String, Integer> getLocationHealthStatusCount() {
        Map<String, Integer> healthStatusCountMap = new Map<String, Integer>();
        
        // Query to count locations by status
        for(AggregateResult ar : [
            SELECT Status__c, COUNT(Id) countOfLocations
            FROM Location__c
            GROUP BY Status__c
        ]) {
            String status = (String)ar.get('Status__c');
            Integer statusCount = (Integer)ar.get('countOfLocations');
            healthStatusCountMap.put(status, statusCount);
        }
        
        // Ensure all status values are represented, even if count is 0
        for(String status : new List<String>{'Green', 'Yellow', 'Orange', 'Red'}) {
            if(!healthStatusCountMap.containsKey(status)) {
                healthStatusCountMap.put(status, 0);
            }
        }
        
        return healthStatusCountMap;
    }
    
    @AuraEnabled
    public static Id addPerson(Person__c personRecord) {
        try {
            if(personRecord != null) {
                // Set status update date to now
                personRecord.Status_Update_Date__c = Date.today();
                
                // Insert the record
                insert personRecord;
                return personRecord.Id;
            }
            return null;
        } catch(Exception e) {
            throw new AuraHandledException('Error creating Person record: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Id addLocation(Location__c locationRecord) {
        try {
            if(locationRecord != null) {
                // Set status update date to now
                locationRecord.Status_Update_Date__c = Date.today();
                
                // Initialize Red_Score__c if it's null
                if(locationRecord.Red_Score__c == null) {
                    locationRecord.Red_Score__c = 0;
                }
                
                // Insert the record
                insert locationRecord;
                return locationRecord.Id;
            }
            return null;
        } catch(Exception e) {
            throw new AuraHandledException('Error creating Location record: ' + e.getMessage());
        }
    }
}