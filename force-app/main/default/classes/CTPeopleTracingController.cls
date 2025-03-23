public with sharing class CTPeopleTracingController {
    /**
     * Get contact traces by person id
     * @param personId Id of the person
     * @return List<People_Tracing__c> List of contact traces
     */
    public static List<People_Tracing__c> getTracesByPersonId(String personId) {
        return [
            SELECT Id, Contact_Date__c, Contact_Type__c, Person_1__c, Person_2__c,
                   Person_1__r.Name, Person_1__r.Health_Status__c, Person_1__r.Mobile__c,
                   Person_2__r.Name, Person_2__r.Health_Status__c, Person_2__r.Mobile__c
            FROM People_Tracing__c
            WHERE Person_1__c = :personId OR Person_2__c = :personId
            ORDER BY Contact_Date__c DESC
        ];
    }
    
    /**
     * Create a new contact trace between two people
     * @param person1Id Id of first person
     * @param person2Id Id of second person
     * @param contactType Type of contact (Direct, Indirect, etc.)
     * @param contactDate Date when contact occurred
     * @return String Id of the newly created trace or error message
     */
    public static String createPeopleTrace(String person1Id, String person2Id, String contactType, Date contactDate) {
        try {
            // Check if trace already exists
            List<People_Tracing__c> existingTraces = [
                SELECT Id FROM People_Tracing__c
                WHERE (Person_1__c = :person1Id AND Person_2__c = :person2Id) OR
                      (Person_1__c = :person2Id AND Person_2__c = :person1Id)
                LIMIT 1
            ];
            
            if (!existingTraces.isEmpty()) {
                return 'Trace already exists between these people.';
            }
            
            // Create new trace
            People_Tracing__c trace = new People_Tracing__c(
                Person_1__c = person1Id,
                Person_2__c = person2Id,
                Contact_Type__c = contactType,
                Contact_Date__c = contactDate
            );
            
            insert trace;
            return trace.Id;
            
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }
    
    /**
     * Get contact traces by record id
     * @param recordId Id to match against both Person_1__c and Person_2__c
     * @return List<People_Tracing__c> List of contact traces
     */
    public static List<People_Tracing__c> getTraces(String recordId) {
        return [
            SELECT Id, Contact_Date__c, Contact_Type__c, Person_1__c, Person_2__c,
                   Person_1__r.Name, Person_1__r.Health_Status__c, Person_1__r.Mobile__c,
                   Person_2__r.Name, Person_2__r.Health_Status__c, Person_2__r.Mobile__c
            FROM People_Tracing__c
            WHERE Person_1__c = :recordId OR Person_2__c = :recordId
            ORDER BY Contact_Date__c DESC
        ];
    }
    
    /**
     * Check for duplicate traces in the provided list
     * @param peopleTraces List of People_Tracing__c records to check for duplicates
     * @return List<People_Tracing__c> List of duplicate traces found in the database
     */
    public static List<People_Tracing__c> checkDuplicates(List<People_Tracing__c> peopleTraces) {
        // Create sets to hold person combinations
        Set<Id> person1Ids = new Set<Id>();
        Set<Id> person2Ids = new Set<Id>();
        
        // Map to track the person combinations we're looking for
        Map<String, People_Tracing__c> personCombinationMap = new Map<String, People_Tracing__c>();
        
        // Extract IDs and build combination keys
        for (People_Tracing__c trace : peopleTraces) {
            person1Ids.add(trace.Person_1__c);
            person2Ids.add(trace.Person_2__c);
            
            // Create unique key for this combination (smaller ID first to handle both directions)
            String key = trace.Person_1__c < trace.Person_2__c ? 
                         trace.Person_1__c + '-' + trace.Person_2__c : 
                         trace.Person_2__c + '-' + trace.Person_1__c;
            
            personCombinationMap.put(key, trace);
        }
        
        // Query existing traces for these people
        List<People_Tracing__c> existingTraces = [
            SELECT Id, Person_1__c, Person_2__c
            FROM People_Tracing__c
            WHERE (Person_1__c IN :person1Ids AND Person_2__c IN :person2Ids) OR
                  (Person_1__c IN :person2Ids AND Person_2__c IN :person1Ids)
        ];
        
        // Find duplicates
        List<People_Tracing__c> duplicates = new List<People_Tracing__c>();
        
        for (People_Tracing__c existingTrace : existingTraces) {
            // Create key in same format as above
            String key = existingTrace.Person_1__c < existingTrace.Person_2__c ? 
                         existingTrace.Person_1__c + '-' + existingTrace.Person_2__c : 
                         existingTrace.Person_2__c + '-' + existingTrace.Person_1__c;
            
            // If this combination exists in our input, it's a duplicate
            if (personCombinationMap.containsKey(key)) {
                duplicates.add(existingTrace);
            }
        }
        
        return duplicates;
    }
}