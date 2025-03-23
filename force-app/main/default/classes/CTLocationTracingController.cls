public with sharing class CTLocationTracingController {
    /**
     * Get location traces by location id
     * @param locationId Id of the location
     * @return List<Location_Tracing__c> List of location traces
     */
    public static List<Location_Tracing__c> getVisitors(String locationId) {
        return [
            SELECT Id, Person__c, Location__c, Visit_Date__c,
                   Person__r.Name, Person__r.Health_Status__c, Person__r.Mobile__c, Person__r.Token__c
            FROM Location_Tracing__c
            WHERE Location__c = :locationId
            ORDER BY Visit_Date__c DESC
        ];
    }
    
    /**
     * Get location traces by person id
     * @param personId Id of the person
     * @return List<Location_Tracing__c> List of location traces
     */
    public static List<Location_Tracing__c> getLocationsByPersonId(String personId) {
        return [
            SELECT Id, Person__c, Location__c, Visit_Date__c,
                   Location__r.Name, Location__r.Address__c, Location__r.Pincode__c, Location__r.Status__c
            FROM Location_Tracing__c
            WHERE Person__c = :personId
            ORDER BY Visit_Date__c DESC
        ];
    }
    
    /**
     * Get location traces by multiple person ids for the last 10 days
     * @param personIds Set of person ids
     * @return List<Location_Tracing__c> List of location traces
     */
    public static List<Location_Tracing__c> getLocationsByPersonIds(Set<Id> personIds) {
        // Calculate date 10 days ago
        Date tenDaysAgo = Date.today().addDays(-10);
        
        return [
            SELECT Id, Person__c, Location__c, Visit_Date__c,
                   Location__r.Name, Location__r.Address__c, Location__r.Pincode__c, Location__r.Status__c
            FROM Location_Tracing__c
            WHERE Person__c IN :personIds
            AND Visit_Date__c >= :tenDaysAgo
            ORDER BY Visit_Date__c DESC
        ];
    }
    
    /**
     * Get location traces by multiple location ids for the last 10 days
     * where person health status is 'Green'
     * @param locationIds Set of location ids
     * @return List<Location_Tracing__c> List of location traces
     */
    public static List<Location_Tracing__c> getLocationsByLocationIds(Set<Id> locationIds) {
        // Calculate date 10 days ago
        Date tenDaysAgo = Date.today().addDays(-10);
        
        return [
            SELECT Id, Person__c, Location__c, Visit_Date__c,
                   Person__r.Name, Person__r.Health_Status__c, Person__r.Mobile__c, Person__r.Token__c
            FROM Location_Tracing__c
            WHERE Location__c IN :locationIds
            AND Person__r.Health_Status__c = 'Green'
            AND Visit_Date__c >= :tenDaysAgo
            ORDER BY Visit_Date__c DESC
        ];
    }
    
    /**
     * Create a new location trace record
     * @param personId Id of the person who visited the location
     * @param locationId Id of the visited location
     * @param visitDate Date of the visit
     * @return String Id of the newly created trace or error message
     */
    public static String createLocationTrace(String personId, String locationId, Date visitDate) {
        try {
            // Check if trace already exists
            List<Location_Tracing__c> existingTraces = [
                SELECT Id FROM Location_Tracing__c
                WHERE Person__c = :personId AND Location__c = :locationId AND Visit_Date__c = :visitDate
                LIMIT 1
            ];
            
            if (!existingTraces.isEmpty()) {
                return 'Trace already exists for this person and location on the given date.';
            }
            
            // Create new trace
            Location_Tracing__c trace = new Location_Tracing__c(
                Person__c = personId,
                Location__c = locationId,
                Visit_Date__c = visitDate
            );
            
            insert trace;
            return trace.Id;
            
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }
    
    /**
     * Check for duplicate location tracing records
     * @param locationTraces List of location tracing records to check
     * @return List<Location_Tracing__c> List of existing duplicate records
     */
    public static List<Location_Tracing__c> checkDuplicates(List<Location_Tracing__c> locationTraces) {
        // Maps to track duplicates
        Map<String, Location_Tracing__c> uniqueKeyToRecordMap = new Map<String, Location_Tracing__c>();
        Set<String> duplicateKeys = new Set<String>();
        
        // First find duplicates within the input list
        for (Location_Tracing__c trace : locationTraces) {
            // Create a composite key
            String key = String.valueOf(trace.Person__c) + '-' + 
                         String.valueOf(trace.Location__c) + '-' + 
                         (trace.Visit_Date__c != null ? String.valueOf(trace.Visit_Date__c) : 'null');
            
            // If this key already exists in our map, it's a duplicate
            if (uniqueKeyToRecordMap.containsKey(key)) {
                duplicateKeys.add(key);
            } else {
                uniqueKeyToRecordMap.put(key, trace);
            }
        }
        
        // Extract criteria for database query
        Set<Id> personIds = new Set<Id>();
        Set<Id> locationIds = new Set<Id>();
        Set<Date> visitDates = new Set<Date>();
        Boolean hasNullDates = false;
        
        for (Location_Tracing__c trace : locationTraces) {
            personIds.add(trace.Person__c);
            locationIds.add(trace.Location__c);
            if (trace.Visit_Date__c != null) {
                visitDates.add(trace.Visit_Date__c);
            } else {
                hasNullDates = true;
            }
        }
        
        // Query for existing duplicates in database
        List<Location_Tracing__c> existingRecords = new List<Location_Tracing__c>();
        
        String query = 'SELECT Id, Person__c, Location__c, Visit_Date__c ' +
                      'FROM Location_Tracing__c ' +
                      'WHERE Person__c IN :personIds ' +
                      'AND Location__c IN :locationIds';
                      
        if (!visitDates.isEmpty() && hasNullDates) {
            query += ' AND (Visit_Date__c IN :visitDates OR Visit_Date__c = null)';
        } else if (!visitDates.isEmpty()) {
            query += ' AND Visit_Date__c IN :visitDates';
        } else if (hasNullDates) {
            query += ' AND Visit_Date__c = null';
        }
        
        existingRecords = Database.query(query);
        
        // Find database records that match our input records
        List<Location_Tracing__c> duplicates = new List<Location_Tracing__c>();
        
        for (Location_Tracing__c dbRecord : existingRecords) {
            String key = String.valueOf(dbRecord.Person__c) + '-' + 
                        String.valueOf(dbRecord.Location__c) + '-' + 
                        (dbRecord.Visit_Date__c != null ? String.valueOf(dbRecord.Visit_Date__c) : 'null');
                        
            if (uniqueKeyToRecordMap.containsKey(key)) {
                duplicates.add(dbRecord);
            }
        }
        
        return duplicates;
    }
    
    // Helper class to store person-location-date combinations
    private class PersonLocationDateKey {
        public Id personId;
        public Id locationId;
        public Date visitDate;
        
        public PersonLocationDateKey(Id personId, Id locationId, Date visitDate) {
            this.personId = personId;
            this.locationId = locationId;
            this.visitDate = visitDate;
        }
    }
}