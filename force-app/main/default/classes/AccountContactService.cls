/**
 * @description Service class for Account and Contact related operations
 */
public with sharing class AccountContactService {
    /**
     * @description Updates the Active_Contacts__c field on Account records
     * by counting related contacts where Active__c is true
     * @param accountIds Set of Account Ids to update
     */
    public static void updateActiveContacts(Set<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty()) {
            return;
        }
        
        // Query for aggregated active contacts per account
        Map<Id, Integer> accountToActiveContactsMap = new Map<Id, Integer>();
        
        // Initialize map with zero counts
        for (Id accId : accountIds) {
            accountToActiveContactsMap.put(accId, 0);
        }
        
        // Count active contacts for each account
        for (AggregateResult ar : [
            SELECT AccountId, COUNT(Id) contactCount
            FROM Contact
            WHERE AccountId IN :accountIds
            AND Active__c = true
            GROUP BY AccountId
        ]) {
            Id accountId = (Id)ar.get('AccountId');
            Integer contactCount = (Integer)ar.get('contactCount');
            accountToActiveContactsMap.put(accountId, contactCount);
        }
        
        // Update accounts with counts
        List<Account> accountsToUpdate = new List<Account>();
        for (Id accId : accountToActiveContactsMap.keySet()) {
            accountsToUpdate.add(new Account(
                Id = accId,
                Active_Contacts__c = accountToActiveContactsMap.get(accId)
            ));
        }
        
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}