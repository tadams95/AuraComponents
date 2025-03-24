public with sharing class CTHealthAdminController {
    
    /**
     * Create a new Location record
     * @param locationObj Location object with details
     * @return Id of the newly created Location record
     */
    @AuraEnabled
    public static String createLocation(Location__c locationObj) {
        try {
            System.debug('Creating location with status: ' + locationObj.Status__c);
            
            // Set Status Update Date to current date
            locationObj.Status_Update_Date__c = Date.today();
            
            // Insert the record
            insert locationObj;
            return locationObj.Id;
        } catch (Exception e) {
            System.debug('Error creating location: ' + e.getMessage() + ', Stack: ' + e.getStackTraceString());
            throw new AuraHandledException('Error creating Location: ' + e.getMessage());
        }
    }
    
    /**
     * Get health status counts
     * @return Map<String, Integer> Map with counts for each status
     */
    @AuraEnabled
    public static Map<String, Integer> getHealthStatusCounts() {
        Map<String, Integer> statusCounts = new Map<String, Integer>();
        
        // Initialize counts
        statusCounts.put('Green', 0);
        statusCounts.put('Yellow', 0);
        statusCounts.put('Orange', 0);
        statusCounts.put('Red', 0);
        
        // Fixed query - Using proper alias syntax
        for (AggregateResult ar : [
            SELECT Health_Status__c, COUNT(Id) countRecords
            FROM Person__c 
            WHERE Health_Status__c IN ('Green', 'Yellow', 'Orange', 'Red')
            GROUP BY Health_Status__c
        ]) {
            String status = (String)ar.get('Health_Status__c');
            Integer count = (Integer)ar.get('countRecords');
            statusCounts.put(status, count);
        }
        
        return statusCounts;
    }
}
