public class CTPersonTriggerHandler {
    
    public static void handleBeforeInsertUpdate(List<Person__c> newRecords) {
        for (Person__c person : newRecords) {
            person.Health_Status__c = 'Green';
            person.Token__c = CTPersonController.getToken(person.Mobile__c);
           }  
    }
    
    public static void handleBeforeUpdate(List<Person__c> newRecords, Map<Id, Person__c> oldMap) {
        for (Person__c person : newRecords){
           
            if (person.Health_Status__c != oldMap.get(person.Id).Health_Status__c) {
                person.Status_Update_Date__c = Date.today();
            }
        }
        
    }
    
    public static void handleAfterUpdate(List<Person__c> newRecords, Map<Id, Person__c> oldRecordsMap) {
        List<Person__c> personsWithChangedHealthStatus = new List<Person__c>();
        List<Person__c> personsChangedToRed = new List<Person__c>();
        
        // Find persons with changed health status and those newly marked as Red
        for (Person__c person : newRecords) {
            Person__c oldPerson = oldRecordsMap.get(person.Id);
            
            if (person.Health_Status__c != oldPerson.Health_Status__c) {
                personsWithChangedHealthStatus.add(person);
                
                if (person.Health_Status__c == 'Red' && oldPerson.Health_Status__c != 'Red') {
                    personsChangedToRed.add(person);
                }
            }
        }
        
        // Process health status changes
        if (!personsWithChangedHealthStatus.isEmpty()) {
            updateLocationHealthStatus(personsWithChangedHealthStatus);
        }
        
        // Process persons newly marked as Red
        if (!personsChangedToRed.isEmpty()) {
            updateContactHealthStatus(personsChangedToRed);
        }
    }
    
    private static void updateLocationHealthStatus(List<Person__c> persons) {
        Set<Id> personIds = new Set<Id>();
        for (Person__c person : persons) {
            personIds.add(person.Id);
        }
        
        // Get date from 10 days ago
        Date tenDaysAgo = Date.today().addDays(-10);
        
        // Query for all location visits in the last 10 days
        List<Location_Tracing__c> locationTraces = [
            SELECT Id, Location__c, Person__c, Visit_Date__c
            FROM Location_Tracing__c
            WHERE Person__c IN :personIds AND Visit_Date__c >= :tenDaysAgo
        ];
        
        // Group location visits by location ID
        Map<Id, List<Location_Tracing__c>> locationToVisitsMap = new Map<Id, List<Location_Tracing__c>>();
        Set<Id> locationIds = new Set<Id>();
        
        for (Location_Tracing__c trace : locationTraces) {
            locationIds.add(trace.Location__c);
            
            if (!locationToVisitsMap.containsKey(trace.Location__c)) {
                locationToVisitsMap.put(trace.Location__c, new List<Location_Tracing__c>());
            }
            locationToVisitsMap.get(trace.Location__c).add(trace);
        }
        
        // Query for the locations
        List<Location__c> locationsToUpdate = [
            SELECT Id, Red_Score__c, Status__c
            FROM Location__c
            WHERE Id IN :locationIds
        ];
        
        // Update Red_Score and Status for affected locations
        for (Location__c location : locationsToUpdate) {
            // Calculate new red score based on visitors
            Integer redVisitors = 0;
            List<Location_Tracing__c> visits = locationToVisitsMap.get(location.Id);
            
            // Query persons related to visits to get their current health status
            Set<Id> visitPersonIds = new Set<Id>();
            for (Location_Tracing__c visit : visits) {
                visitPersonIds.add(visit.Person__c);
            }
            
            Map<Id, Person__c> personMap = new Map<Id, Person__c>([
                SELECT Id, Health_Status__c
                FROM Person__c
                WHERE Id IN :visitPersonIds
            ]);
            
            // Count red visitors
            for (Location_Tracing__c visit : visits) {
                Person__c visitPerson = personMap.get(visit.Person__c);
                if (visitPerson.Health_Status__c == 'Red') {
                    redVisitors++;
                }
            }
            
            // Update location Red_Score
            location.Red_Score__c = redVisitors;
            
            // Update location Status based on Red_Score
            if (redVisitors > 10) {
                location.Status__c = 'Red';
            } else if (redVisitors > 5) {
                location.Status__c = 'Orange';
            } else if (redVisitors > 0) {
                location.Status__c = 'Yellow';
            } else {
                location.Status__c = 'Green';
            }
        }
        
        // Update locations
        if (!locationsToUpdate.isEmpty()) {
            update locationsToUpdate;
        }
    }
    
    private static void updateContactHealthStatus(List<Person__c> redPersons) {
        Set<Id> redPersonIds = new Set<Id>();
        for (Person__c person : redPersons) {
            redPersonIds.add(person.Id);
        }
        
        // Get all cohabitants - update to Orange except Red and Orange ones
        Set<Id> cohabitantIds = new Set<Id>();
        for (People_Tracing__c pt : [
            SELECT Id, Person_1__c, Person_2__c
            FROM People_Tracing__c
            WHERE (Person_1__c IN :redPersonIds OR Person_2__c IN :redPersonIds)
            AND Contact_Type__c = 'Cohabitant'
        ]) {
            if (redPersonIds.contains(pt.Person_1__c)) {
                cohabitantIds.add(pt.Person_2__c);
            } else {
                cohabitantIds.add(pt.Person_1__c);
            }
        }
        
        // Get all primary contacts - update to Orange except Red and Orange ones
        Set<Id> primaryContactIds = new Set<Id>();
        for (People_Tracing__c pt : [
            SELECT Id, Person_1__c, Person_2__c
            FROM People_Tracing__c
            WHERE (Person_1__c IN :redPersonIds OR Person_2__c IN :redPersonIds)
            AND Contact_Type__c = 'Primary'
        ]) {
            if (redPersonIds.contains(pt.Person_1__c)) {
                primaryContactIds.add(pt.Person_2__c);
            } else {
                primaryContactIds.add(pt.Person_1__c);
            }
        }
        
        // Get all neighbors - update to Yellow except Red, Orange and Yellow ones
        Set<Id> neighborIds = new Set<Id>();
        for (People_Tracing__c pt : [
            SELECT Id, Person_1__c, Person_2__c
            FROM People_Tracing__c
            WHERE (Person_1__c IN :redPersonIds OR Person_2__c IN :redPersonIds)
            AND Contact_Type__c = 'Neighbor'
        ]) {
            if (redPersonIds.contains(pt.Person_1__c)) {
                neighborIds.add(pt.Person_2__c);
            } else {
                neighborIds.add(pt.Person_1__c);
            }
        }
        
        // Get all secondary contacts - update to Yellow except Red, Orange and Yellow ones
        Set<Id> secondaryContactIds = new Set<Id>();
        for (People_Tracing__c pt : [
            SELECT Id, Person_1__c, Person_2__c
            FROM People_Tracing__c
            WHERE (Person_1__c IN :redPersonIds OR Person_2__c IN :redPersonIds)
            AND Contact_Type__c = 'Secondary'
        ]) {
            if (redPersonIds.contains(pt.Person_1__c)) {
                secondaryContactIds.add(pt.Person_2__c);
            } else {
                secondaryContactIds.add(pt.Person_1__c);
            }
        }
        
        // Get all persons that need to be updated
        List<Person__c> personsToUpdate = [
            SELECT Id, Health_Status__c
            FROM Person__c
            WHERE (
                (Id IN :cohabitantIds OR Id IN :primaryContactIds) AND 
                Health_Status__c NOT IN ('Red', 'Orange')
            ) OR (
                (Id IN :neighborIds OR Id IN :secondaryContactIds) AND 
                Health_Status__c NOT IN ('Red', 'Orange', 'Yellow')
            )
        ];
        
        // Update health status
        for (Person__c p : personsToUpdate) {
            if (cohabitantIds.contains(p.Id) || primaryContactIds.contains(p.Id)) {
                p.Health_Status__c = 'Orange';
            } else if (neighborIds.contains(p.Id) || secondaryContactIds.contains(p.Id)) {
                p.Health_Status__c = 'Yellow';
            }
        }
        
        // Update persons
        if (!personsToUpdate.isEmpty()) {
            update personsToUpdate;
        }
        
        // Update location status and red scores
        updateLocationHealthStatus(redPersons);
    }
}