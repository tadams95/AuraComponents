public with sharing class CTPersonController {
    /**
     * Get recent contacts for a person
     * @param personId Id of the person
     * @return List<Contact> List of contacts
     */
    public static List<Person__c> getRecentContacts(String personId) {
        List<People_Tracing__c> peopleTraces = [
            SELECT Id, Contact_Date__c, Person_1__c, Person_2__c 
            FROM People_Tracing__c 
            WHERE (Person_1__c = :personId OR Person_2__c = :personId)
            ORDER BY Contact_Date__c DESC
        ];
        
        Set<Id> personIds = new Set<Id>();
        for(People_Tracing__c pt : peopleTraces) {
            if(pt.Person_1__c == personId) {
                personIds.add(pt.Person_2__c);
            } else {
                personIds.add(pt.Person_1__c);
            }
        }
        
        return [SELECT Id, Name, Health_Status__c, Mobile__c, Token__c 
                FROM Person__c 
                WHERE Id IN :personIds
                ORDER BY Name];
    }
    
    /**
     * Get all people with their health status counts
     * @return Map<String, Integer> Map of health status and its count
     */
    public static Map<String, Integer> getHealthStatusCount() {
        Map<String, Integer> healthStatusCount = new Map<String, Integer>();
        for(AggregateResult ar : [
            SELECT Health_Status__c, COUNT(Id) total
            FROM Person__c
            GROUP BY Health_Status__c
        ]) {
            String status = (String)ar.get('Health_Status__c');
            Integer count = (Integer)ar.get('total');
            healthStatusCount.put(status, count);
        }
        return healthStatusCount;
    }
    
    /**
     * Search people by name, token or mobile
     * @param searchTerm Search term
     * @return List<Person__c> List of people matching the search term
     */
    public static List<Person__c> searchPeople(String searchTerm) {
        searchTerm = '%' + searchTerm + '%';
        return [
            SELECT Id, Name, Health_Status__c, Mobile__c, Token__c, Status_Update_Date__c,
                   CreatedDate, LastModifiedDate
            FROM Person__c 
            WHERE Name LIKE :searchTerm 
                OR Mobile__c LIKE :searchTerm 
                OR Token__c LIKE :searchTerm
            ORDER BY Status_Update_Date__c DESC
        ];
    }
    
    /**
     * Get a person by id
     * @param personId Id of the person
     * @return Person__c Person record
     */
    public static Person__c getPersonById(String personId) {
        List<Person__c> people = [
            SELECT Id, Name, Health_Status__c, Mobile__c, Token__c, 
                   Status_Update_Date__c, CreatedDate, LastModifiedDate
            FROM Person__c 
            WHERE Id = :personId
        ];
        if(people != null && people.size() > 0) {
            return people[0];
        }
        return null;
    }
    
    /**
     * Get recent health changes
     * @return List<Person__c> List of people with recent health status changes
     */
    public static List<Person__c> getRecentHealthChanges() {
        return [
            SELECT Id, Name, Health_Status__c, Mobile__c, Token__c, 
                   Status_Update_Date__c, CreatedDate, LastModifiedDate
            FROM Person__c 
            ORDER BY Status_Update_Date__c DESC
            LIMIT 100
        ];
    }
    
    /**
     * Generate a secure token using MD5 hashing based on mobile number
     * @param mobileNo Mobile number to generate token for
     * @return String Secure token
     */
    public static String getToken(String mobileNo) {
        if (String.isBlank(mobileNo)) {
            return null;
        }
        
        // Add a salt and current timestamp to make the token more secure
        String input = mobileNo + System.now().getTime();
        
        // Generate MD5 hash
        Blob inputBlob = Blob.valueOf(input);
        Blob hashBlob = Crypto.generateDigest('MD5', inputBlob);
        
        // Convert the blob to a hex string
        String hexToken = EncodingUtil.convertToHex(hashBlob);
        
        // Return first 16 characters of the token
        return hexToken.substring(0, 16).toUpperCase();
    }
}