/**
 * @description Handler class for Contact trigger operations
 * This class contains methods to handle various trigger contexts for the Contact object
 * and manages the counting of active contacts related to accounts
 */
public with sharing class ContactTriggerHandler {
    /**
     * @description Handles logic after Contact records are inserted
     * Counts active contacts for related accounts and updates the Active_Contacts__c field
     * @param newContacts List of newly inserted Contact records
     */
    public static void afterInsertHandler(List<Contact> newContacts) {
        Set<Id> accountIds = new Set<Id>();
        for (Contact con : newContacts) {
            if (String.isNotBlank(con.AccountId)) {
                // write automation logic here
                accountIds.add(con.AccountId);
            }
        }
        AccountContactService.updateActiveContacts(accountIds);
    }

    /**
     * @description Handles logic after Contact records are updated
     * Recalculates active contacts for related accounts and updates the Active_Contacts__c field
     * @param updatedContacts List of updated Contact records
     * @param oldContactMap Map of old Contact records before the update
     */
    public static void afterUpdateHandler(List<Contact> newContacts, Map<Id, Contact> oldContactsMap) {
        Set<Id> accountIds = new Set<Id>();
        for (Contact con : newContacts) {
            // capture the account id only if active checkbox value is flipped
            if (String.isNotBlank(con.AccountId) && oldContactsMap.get(con.Id).Active__c != con.Active__c) {
                // write automation logic here
                accountIds.add(con.AccountId);
            } else if (oldContactsMap.get(con.Id).AccountId != con.AccountId) {
                accountIds.add(con.AccountId);
                accountIds.add(oldContactsMap.get(con.Id).AccountId);
            }
        }
        AccountContactService.updateActiveContacts(accountIds);
    }

    public static void afterDeleteHandler(List<Contact> deletedContacts) {
        Set<Id> accountIds = new Set<Id>();
        for (Contact con : deletedContacts) {
            if (String.isNotBlank(con.AccountId)) {
                // write automation logic here
                accountIds.add(con.AccountId);
            }
        }
        AccountContactService.updateActiveContacts(accountIds);
    }

    public static void afterUndeleteHandler(List<Contact> undeletedContacts) {
        Set<Id> accountIds = new Set<Id>();
        for (Contact con : undeletedContacts) {
            if (String.isNotBlank(con.AccountId)) {
                // write automation logic here
                accountIds.add(con.AccountId);
            }
        }
        AccountContactService.updateActiveContacts(accountIds);
    }

}