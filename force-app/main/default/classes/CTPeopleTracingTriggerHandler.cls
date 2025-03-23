public with sharing class CTPeopleTracingTriggerHandler {
    public static void beforeInsert(List<People_Tracing__c> newPeopleTracing) {
        // Set contact date to today if not provided
        for(People_Tracing__c peopleTracing : newPeopleTracing) {
            if(peopleTracing.Contact_Date__c == null) {
                peopleTracing.Contact_Date__c = Date.today();
            }
        }
        
        // Check for duplicates
        checkDuplicates(newPeopleTracing);
    }
    
    public static void beforeUpdate(List<People_Tracing__c> newPeopleTracing, Map<Id, People_Tracing__c> oldPeopleTracingMap) {
        // Future implementation for beforeUpdate logic
    }
    
    public static void afterUpdate(List<People_Tracing__c> newPeopleTracing, Map<Id, People_Tracing__c> oldPeopleTracingMap) {
        // Future implementation for afterUpdate logic
    }
    
    private static void checkDuplicates(List<People_Tracing__c> peopleTracingList) {
        // Create a set of composite keys for quick lookup
        Set<String> newPeopleTracingKeys = new Set<String>();
        Map<String, People_Tracing__c> newKeysToRecords = new Map<String, People_Tracing__c>();
        
        // Process incoming records to identify potential duplicates within the trigger set
        for(People_Tracing__c pt : peopleTracingList) {
            // Create a unique key based on the two person records
            // We'll create two keys to check both directions (Person1__c -> Person2__c and Person2__c -> Person1__c)
            String key1 = String.valueOf(pt.Person_1__c) + '-' + String.valueOf(pt.Person_2__c);
            String key2 = String.valueOf(pt.Person_2__c) + '-' + String.valueOf(pt.Person_1__c);
            
            // Check for duplicates within the current trigger batch
            if(newPeopleTracingKeys.contains(key1) || newPeopleTracingKeys.contains(key2)) {
                pt.addError('Duplicate record found. A record for these two people already exists.');
            } else {
                newPeopleTracingKeys.add(key1);
                newKeysToRecords.put(key1, pt);
            }
        }
        
        // Query existing records to check for duplicates in the database
        List<People_Tracing__c> existingRecords = [
            SELECT Id, Person_1__c, Person_2__c 
            FROM People_Tracing__c 
            WHERE (Person_1__c IN :getPersonIds(peopleTracingList) AND Person_2__c IN :getPersonIds(peopleTracingList))
        ];
        
        // Check each existing record against incoming records
        for(People_Tracing__c existingPT : existingRecords) {
            String existingKey1 = String.valueOf(existingPT.Person_1__c) + '-' + String.valueOf(existingPT.Person_2__c);
            String existingKey2 = String.valueOf(existingPT.Person_2__c) + '-' + String.valueOf(existingPT.Person_1__c);
            
            // Find the corresponding new record if any
            for(People_Tracing__c newPT : peopleTracingList) {
                String newKey1 = String.valueOf(newPT.Person_1__c) + '-' + String.valueOf(newPT.Person_2__c);
                String newKey2 = String.valueOf(newPT.Person_2__c) + '-' + String.valueOf(newPT.Person_1__c);
                
                if(newKey1.equals(existingKey1) || newKey1.equals(existingKey2) || 
                   newKey2.equals(existingKey1) || newKey2.equals(existingKey2)) {
                    newPT.addError('Duplicate record found. A record for these two people already exists in the database.');
                }
            }
        }
    }
    
    private static Set<Id> getPersonIds(List<People_Tracing__c> peopleTracingList) {
        Set<Id> personIds = new Set<Id>();
        for(People_Tracing__c pt : peopleTracingList) {
            personIds.add(pt.Person_1__c);
            personIds.add(pt.Person_2__c);
        }
        return personIds;
    }
}