public with sharing class CTLocationTracingTriggerHandler {
    /**
     * Handle before insert trigger event
     * Check for duplicates and add errors to duplicate records
     * @param newRecords List of Location_Tracing__c records in the trigger context
     */
    public static void beforeInsert(List<Location_Tracing__c> newRecords) {
        // Use the controller to check for duplicates
        List<Location_Tracing__c> duplicates = CTLocationTracingController.checkDuplicates(newRecords);
        
        // If duplicates found, add error messages
        if(!duplicates.isEmpty()) {
            // Create a map of unique keys to duplicate records
            Map<String, Location_Tracing__c> duplicateMap = new Map<String, Location_Tracing__c>();
            
            for(Location_Tracing__c duplicate : duplicates) {
                String key = String.valueOf(duplicate.Person__c) + '-' + 
                             String.valueOf(duplicate.Location__c) + '-' + 
                             (duplicate.Visit_Date__c != null ? String.valueOf(duplicate.Visit_Date__c) : 'null');
                duplicateMap.put(key, duplicate);
            }
            
            // Check each new record against the duplicate map
            for(Location_Tracing__c newRecord : newRecords) {
                String key = String.valueOf(newRecord.Person__c) + '-' + 
                             String.valueOf(newRecord.Location__c) + '-' + 
                             (newRecord.Visit_Date__c != null ? String.valueOf(newRecord.Visit_Date__c) : 'null');
                
                if(duplicateMap.containsKey(key)) {
                    newRecord.addError('Duplicate record found. A record already exists for this person and location on the selected date.');
                }
            }
        }
    }
}