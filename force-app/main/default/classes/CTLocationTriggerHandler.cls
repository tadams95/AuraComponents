public with sharing class CTLocationTriggerHandler {
    public static void beforeInsert(List<Location__c> newLocations) {
        for(Location__c location : newLocations) {
            if(location.Status__c == null) {
                location.Status__c = 'Green';
            }
        }
    }

    public static void beforeUpdate(List<Location__c> newLocations, Map<Id, Location__c> oldMap) {
        for(Location__c location : newLocations) {
            // Get the old version of the record
            Location__c oldLocation = oldMap.get(location.Id);
            
            // Check if status has changed
            if(location.Status__c != oldLocation.Status__c) {
                location.Status_Update_Date__c = Date.today();
            }
        }
    }
    public static void afterUpdate(List<Location__c> newLocations, Map<Id, Location__c> oldMap) {
        List<Location__c> locationsWithChangedStatus = new List<Location__c>();
        List<Location__c> locationsChangedToRed = new List<Location__c>();
        
        // Find locations with changed status and those newly marked as Red
        for(Location__c location : newLocations) {
            Location__c oldLocation = oldMap.get(location.Id);
            
            if(location.Status__c != oldLocation.Status__c) {
                locationsWithChangedStatus.add(location);
                
                if(location.Status__c == 'Red' && oldLocation.Status__c != 'Red') {
                    locationsChangedToRed.add(location);
                }
            }
        }
        
        // Process status changes
        if(!locationsWithChangedStatus.isEmpty()) {
            updateLocationTracing(locationsWithChangedStatus);
        }
        
        // Process locations newly marked as Red
        if(!locationsChangedToRed.isEmpty()) {
            updatePersonHealthStatus(locationsChangedToRed);
        }
    }
    
    /**
     * Update contact tracing records when location status changes
     * @param locations List of locations with changed status
     */
    private static void updateLocationTracing(List<Location__c> locations) {
        Set<Id> locationIds = new Set<Id>();
        for(Location__c location : locations) {
            locationIds.add(location.Id);
        }
        
        // Find all people who visited these locations in the last 10 days
        List<Location_Tracing__c> locationTraces = CTLocationTracingController.getLocationsByLocationIds(locationIds);
        
        // If there are no visitors in the last 10 days, no action needed
        if(locationTraces.isEmpty()) {
            return;
        }
        
        // Process the health status updates for affected people
        Set<Id> personIds = new Set<Id>();
        for(Location_Tracing__c trace : locationTraces) {
            personIds.add(trace.Person__c);
        }
        
        // Update status for all affected people
        List<Person__c> peopleToUpdate = [
            SELECT Id, Health_Status__c 
            FROM Person__c 
            WHERE Id IN :personIds
        ];
        
        for(Person__c person : peopleToUpdate) {
            person.Health_Status__c = 'Yellow';
            person.Status_Update_Date__c = Date.today();
        }
        
        if(!peopleToUpdate.isEmpty()) {
            update peopleToUpdate;
        }
    }
    
    /**
     * Update health status of people who visited locations newly marked as Red
     * @param redLocations List of locations newly marked as Red
     */
    private static void updatePersonHealthStatus(List<Location__c> redLocations) {
        Set<Id> redLocationIds = new Set<Id>();
        for(Location__c location : redLocations) {
            redLocationIds.add(location.Id);
        }
        
        // Find people who visited these locations in the last 10 days
        List<Location_Tracing__c> locationTraces = [
            SELECT Id, Person__c, Location__c, Visit_Date__c
            FROM Location_Tracing__c
            WHERE Location__c IN :redLocationIds
            AND Visit_Date__c >= LAST_N_DAYS:10
        ];
        
        if(locationTraces.isEmpty()) {
            return;
        }
        
        // Get all people who need to be updated to Orange status
        Set<Id> personIds = new Set<Id>();
        for(Location_Tracing__c trace : locationTraces) {
            personIds.add(trace.Person__c);
        }
        
        List<Person__c> peopleToUpdate = [
            SELECT Id, Health_Status__c 
            FROM Person__c 
            WHERE Id IN :personIds
            AND Health_Status__c != 'Red' // Don't downgrade already Red people
        ];
        
        for(Person__c person : peopleToUpdate) {
            person.Health_Status__c = 'Orange';
            person.Status_Update_Date__c = Date.today();
        }
        
        if(!peopleToUpdate.isEmpty()) {
            update peopleToUpdate;
        }
    }
}