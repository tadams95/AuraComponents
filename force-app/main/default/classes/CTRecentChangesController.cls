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
    
    @AuraEnabled
    public static List<LocationHealthWrapper> getRecentLocationHealthChanges(String searchTerm) {
        // If searchTerm is provided, use it to filter results
        String searchQuery = '%' + String.escapeSingleQuotes(String.isBlank(searchTerm) ? '' : searchTerm) + '%';
        
        // Query for recent location health changes
        List<Location__c> locations = [
            SELECT Id, Name, Status__c, Pincode__c, Address__c, Red_Score__c, Status_Update_Date__c
            FROM Location__c 
            WHERE Name LIKE :searchQuery OR Pincode__c LIKE :searchQuery OR Address__c LIKE :searchQuery
            ORDER BY Status_Update_Date__c DESC
            LIMIT 100
        ];
        
        // Convert to wrapper objects for the component
        List<LocationHealthWrapper> wrappers = new List<LocationHealthWrapper>();
        for(Location__c location : locations) {
            wrappers.add(new LocationHealthWrapper(location));
        }
        
        return wrappers;
    }
    
    @AuraEnabled
    public static Object getRecentChanges(String recordType, String searchTerm) {
        if (recordType == 'person') {
            return getRecentPersonHealthChanges(searchTerm);
        } else if (recordType == 'location') {
            return getRecentLocationHealthChanges(searchTerm);
        }
        return null;
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
    
    // Wrapper class to hold location health data
    public class LocationHealthWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String Name;
        @AuraEnabled public String Status;
        @AuraEnabled public String Pincode;
        @AuraEnabled public String Address;
        @AuraEnabled public Decimal RedScore;
        @AuraEnabled public Datetime StatusUpdateDate;
        
        public LocationHealthWrapper(Location__c location) {
            this.id = location.Id;
            this.Name = location.Name;
            this.Status = location.Status__c;
            this.Pincode = location.Pincode__c;
            this.Address = location.Address__c;
            this.RedScore = location.Red_Score__c;
            this.StatusUpdateDate = location.Status_Update_Date__c;
        }
    }
}
