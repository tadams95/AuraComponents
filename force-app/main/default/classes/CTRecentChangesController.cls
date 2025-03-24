public with sharing class CTRecentChangesController {
    
    @AuraEnabled
    public static List<PersonHealthWrapper> getRecentPersonHealthChanges(String searchTerm) {
        // If searchTerm is provided, use it to filter results
        String searchQuery = '%' + String.escapeSingleQuotes(String.isBlank(searchTerm) ? '' : searchTerm) + '%';
        
        // Query for recent health changes
        // Assuming you have Person__c and Health_Status__c objects or similar
        // Modify this query to match your actual data model
        List<Person__c> people = [
            SELECT Id, Name, Mobile__c, Health_Status__c, Status_Update_Date__c, Token__c
            FROM Person__c 
            WHERE Name LIKE :searchQuery OR Mobile__c LIKE :searchQuery OR Token__c LIKE :searchQuery
            ORDER BY Status_Update_Date__c DESC
            LIMIT 100
        ];
        
        // Convert to wrapper objects for the component
        List<PersonHealthWrapper> wrappers = new List<PersonHealthWrapper>();
        for(Person__c person : people) {
            wrappers.add(new PersonHealthWrapper(person));
        }
        
        return wrappers;
    }
    
    // Wrapper class to hold person health data
    public class PersonHealthWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String Name;
        @AuraEnabled public String Mobile;
        @AuraEnabled public String Token;
        @AuraEnabled public String Status;
        @AuraEnabled public Datetime StatusUpdateDate;
        
        public PersonHealthWrapper(Person__c person) {
            this.id = person.Id;
            this.Name = person.Name;
            this.Mobile = person.Mobile__c;
            this.Token = person.Token__c;
            this.Status = person.Health_Status__c;
            this.StatusUpdateDate = person.Status_Update_Date__c;
        }
    }
}
