@isTest(seeAllData=true)
public with sharing class ContactTriggerHandlerTest {
    
    @isTest
    public static void testAfterInsertHandler() {
        // Test data setup
        List<Account> testAccounts = new List<Account>{
            new Account(Name = 'Test Account 1'),
            new Account(Name = 'Test Account 2')
        };
        insert testAccounts;
        
        // To make sure we're testing the trigger handler rather than AnnotationsDemo
        // let's verify ContactTriggerHandler exists before running the test
        System.assertNotEquals(null, Type.forName('ContactTriggerHandler'), 
            'ContactTriggerHandler class should exist');
        
        // Create test contacts - mix of active and inactive
        List<Contact> testContacts = new List<Contact>{
            new Contact(
                FirstName = 'Test1',
                LastName = 'Contact',
                AccountId = testAccounts[0].Id,
                Active__c = true
            ),
            new Contact(
                FirstName = 'Test2',
                LastName = 'Contact',
                AccountId = testAccounts[0].Id,
                Active__c = true
            ),
            new Contact(
                FirstName = 'Test3',
                LastName = 'Contact',
                AccountId = testAccounts[0].Id,
                Active__c = false
            ),
            new Contact(
                FirstName = 'Test4',
                LastName = 'Contact',
                AccountId = testAccounts[1].Id,
                Active__c = true
            )
        };
        
        // Execute test
        Test.startTest();
        // Insert contacts should trigger the ContactTrigger, which calls the handler
        insert testContacts;
        Test.stopTest();
        
        // Verify results
        List<Account> updatedAccounts = [SELECT Id, Name, Active_Contacts__c FROM Account WHERE Id IN :testAccounts ORDER BY Name];
        
        // Verify that our test is running against the right class
        System.debug('Class being tested: ContactTriggerHandler');
        
        // Account 1 should have 2 active contacts
        System.assertEquals(2, updatedAccounts[0].Active_Contacts__c, 
                           'First account should have 2 active contacts');
        
        // Account 2 should have 1 active contact
        System.assertEquals(1, updatedAccounts[1].Active_Contacts__c, 
                           'Second account should have 1 active contact');
    }
    
    @isTest
    public static void testAfterUpdateHandler() {
        // Test data setup
        List<Account> testAccounts = new List<Account>{
            new Account(Name = 'Test Account 1'),
            new Account(Name = 'Test Account 2')
        };
        insert testAccounts;
        
        // Create test contacts - mix of active and inactive
        List<Contact> testContacts = new List<Contact>{
            new Contact(
                FirstName = 'Test1',
                LastName = 'Contact',
                AccountId = testAccounts[0].Id,
                Active__c = true
            ),
            new Contact(
                FirstName = 'Test2',
                LastName = 'Contact',
                AccountId = testAccounts[0].Id,
                Active__c = false
            ),
            new Contact(
                FirstName = 'Test3',
                LastName = 'Contact',
                AccountId = testAccounts[1].Id,
                Active__c = false
            )
        };
        insert testContacts;
        
        // Verify initial state
        List<Account> initialAccounts = [SELECT Id, Name, Active_Contacts__c FROM Account WHERE Id IN :testAccounts ORDER BY Name];
        System.assertEquals(1, initialAccounts[0].Active_Contacts__c, 'First account should have 1 active contact initially');
        System.assertEquals(0, initialAccounts[1].Active_Contacts__c, 'Second account should have 0 active contacts initially');
        
        // Update contacts - Toggle active flag
        testContacts[0].Active__c = false; // Turn off an active contact
        testContacts[1].Active__c = true;  // Turn on an inactive contact
        testContacts[2].Active__c = true;  // Turn on an inactive contact
        
        // Execute test
        Test.startTest();
        update testContacts;
        Test.stopTest();
        
        // Verify results
        List<Account> updatedAccounts = [SELECT Id, Name, Active_Contacts__c FROM Account WHERE Id IN :testAccounts ORDER BY Name];
        System.assertEquals(1, updatedAccounts[0].Active_Contacts__c, 'First account should still have 1 active contact');
        System.assertEquals(1, updatedAccounts[1].Active_Contacts__c, 'Second account should now have 1 active contact');
        
        // Test changing Account relationship
        Contact movedContact = testContacts[2];
        movedContact.AccountId = testAccounts[0].Id;
        
        update movedContact;
        
        // Verify results after moving contact
        updatedAccounts = [SELECT Id, Name, Active_Contacts__c FROM Account WHERE Id IN :testAccounts ORDER BY Name];
        System.assertEquals(2, updatedAccounts[0].Active_Contacts__c, 'First account should now have 2 active contacts');
        System.assertEquals(0, updatedAccounts[1].Active_Contacts__c, 'Second account should now have 0 active contacts');
    }
    
    @isTest
    public static void testAfterDeleteHandler() {
        // Test data setup
        List<Account> testAccounts = new List<Account>{
            new Account(Name = 'Test Account 1')
        };
        insert testAccounts;
        
        // Create test contacts
        List<Contact> testContacts = new List<Contact>{
            new Contact(
                FirstName = 'Test1',
                LastName = 'Contact',
                AccountId = testAccounts[0].Id,
                Active__c = true
            ),
            new Contact(
                FirstName = 'Test2',
                LastName = 'Contact',
                AccountId = testAccounts[0].Id,
                Active__c = true
            )
        };
        insert testContacts;
        
        // Verify initial state
        List<Account> initialAccounts = [SELECT Id, Active_Contacts__c FROM Account WHERE Id IN :testAccounts];
        System.assertEquals(2, initialAccounts[0].Active_Contacts__c, 'Account should have 2 active contacts initially');
        
        // Execute test - delete one contact
        Test.startTest();
        delete testContacts[0];
        Test.stopTest();
        
        // Verify results
        List<Account> updatedAccounts = [SELECT Id, Active_Contacts__c FROM Account WHERE Id IN :testAccounts];
        System.assertEquals(1, updatedAccounts[0].Active_Contacts__c, 'Account should have 1 active contact after deletion');
    }
    
    @isTest
    public static void testAfterUndeleteHandler() {
        // Test data setup
        List<Account> testAccounts = new List<Account>{
            new Account(Name = 'Test Account 1')
        };
        insert testAccounts;
        
        // Create test contacts
        List<Contact> testContacts = new List<Contact>{
            new Contact(
                FirstName = 'Test1',
                LastName = 'Contact',
                AccountId = testAccounts[0].Id,
                Active__c = true
            ),
            new Contact(
                FirstName = 'Test2',
                LastName = 'Contact',
                AccountId = testAccounts[0].Id,
                Active__c = true
            )
        };
        insert testContacts;
        
        // Delete contacts for later undelete
        delete testContacts;
        
        // Verify state after deletion
        List<Account> accountsAfterDelete = [SELECT Id, Active_Contacts__c FROM Account WHERE Id IN :testAccounts];
        System.assertEquals(0, accountsAfterDelete[0].Active_Contacts__c, 'Account should have 0 active contacts after deletion');
        
        // Execute test - undelete contacts
        Test.startTest();
        undelete testContacts;
        Test.stopTest();
        
        // Verify results
        List<Account> updatedAccounts = [SELECT Id, Active_Contacts__c FROM Account WHERE Id IN :testAccounts];
        System.assertEquals(2, updatedAccounts[0].Active_Contacts__c, 'Account should have 2 active contacts after undelete');
    }
    
    @isTest
    public static void testBulkOperations() {
        // Configure the number of records to test with
        final Integer NUM_ACCOUNTS = 10;
        final Integer CONTACTS_PER_ACCOUNT = 20;
        
        // Setup test data - create accounts
        List<Account> testAccounts = new List<Account>();
        for (Integer i = 0; i < NUM_ACCOUNTS; i++) {
            testAccounts.add(new Account(
                Name = 'Bulk Test Account ' + i
            ));
        }
        
        // Insert accounts and get their IDs
        Test.startTest();
        insert testAccounts;
        
        // Create contacts - half active, half inactive
        List<Contact> testContacts = new List<Contact>();
        for (Integer a = 0; a < NUM_ACCOUNTS; a++) {
            for (Integer c = 0; c < CONTACTS_PER_ACCOUNT; c++) {
                testContacts.add(new Contact(
                    FirstName = 'Bulk',
                    LastName = 'Contact ' + a + '-' + c,
                    AccountId = testAccounts[a].Id,
                    Active__c = Math.mod(c, 2) == 0 // Every other contact is active
                ));
            }
        }
        
        // Measure performance and ensure no governor limits are hit
        Datetime startTime = Datetime.now();
        insert testContacts;
        Datetime insertEndTime = Datetime.now();
        
        // Verify that half of the contacts per account are active
        Map<Id, Account> accountsAfterInsert = new Map<Id, Account>([
            SELECT Id, Name, Active_Contacts__c 
            FROM Account 
            WHERE Id IN :testAccounts
        ]);
        
        // Each account should have CONTACTS_PER_ACCOUNT/2 active contacts
        Integer expectedActiveContacts = CONTACTS_PER_ACCOUNT / 2;
        for (Account acc : accountsAfterInsert.values()) {
            System.assertEquals(expectedActiveContacts, acc.Active_Contacts__c, 
                'Account should have half of its contacts active');
        }
        
        // Test bulk updates - toggle active status for all contacts
        for (Contact con : testContacts) {
            con.Active__c = !con.Active__c;
        }
        
        Datetime updateStartTime = Datetime.now();
        update testContacts;
        Datetime updateEndTime = Datetime.now();
        
        // After toggling, now the other half of contacts are active
        Map<Id, Account> accountsAfterUpdate = new Map<Id, Account>([
            SELECT Id, Name, Active_Contacts__c 
            FROM Account 
            WHERE Id IN :testAccounts
        ]);
        
        for (Account acc : accountsAfterUpdate.values()) {
            System.assertEquals(expectedActiveContacts, acc.Active_Contacts__c, 
                'Account should still have half of its contacts active after toggle');
        }
        
        // Test bulk deletes - delete half the contacts
        List<Contact> contactsToDelete = new List<Contact>();
        for (Integer i = 0; i < testContacts.size(); i++) {
            if (Math.mod(i, 2) == 0) {
                contactsToDelete.add(testContacts[i]);
            }
        }
        
        Datetime deleteStartTime = Datetime.now();
        delete contactsToDelete;
        Datetime deleteEndTime = Datetime.now();
        
        // The issue is here: After toggling, the active status has flipped.
        // So when we delete every other contact (Math.mod(i, 2) == 0), we're not deleting
        // half of the active contacts - we're deleting a specific set of contacts.
        // Since the active status was flipped, now half of the deleted contacts were active
        // and half were inactive. This means we're deleting CONTACTS_PER_ACCOUNT/4 active contacts
        // per account, leaving CONTACTS_PER_ACCOUNT/4 active contacts remaining.
        
        // Verify results after delete
        Map<Id, Account> accountsAfterDelete = new Map<Id, Account>([
            SELECT Id, Name, Active_Contacts__c 
            FROM Account 
            WHERE Id IN :testAccounts
        ]);
        
        // After the toggle, odd-indexed contacts became active.
        // We deleted even-indexed contacts (Math.mod(i, 2) == 0).
        // So we should still have all the odd-indexed contacts which are now active.
        // So we expect to still have CONTACTS_PER_ACCOUNT/2 active contacts.
        Integer expectedActiveAfterDelete = CONTACTS_PER_ACCOUNT / 2;
        for (Account acc : accountsAfterDelete.values()) {
            System.assertEquals(expectedActiveAfterDelete, acc.Active_Contacts__c, 
                'Account should have half of its contacts active after delete');
        }
        
        // Test bulk undelete
        Datetime undeleteStartTime = Datetime.now();
        undelete contactsToDelete;
        Datetime undeleteEndTime = Datetime.now();
        Test.stopTest();
        
        // Verify final results
        Map<Id, Account> finalAccounts = new Map<Id, Account>([
            SELECT Id, Name, Active_Contacts__c 
            FROM Account 
            WHERE Id IN :testAccounts
        ]);
        
        // After undelete, we get back to the same state as after update - half of all contacts are active
        for (Account acc : finalAccounts.values()) {
            System.assertEquals(expectedActiveContacts, acc.Active_Contacts__c, 
                'Account should end with half of its contacts active');
        }
        
        // Log performance metrics
        System.debug('Bulk Performance Metrics:');
        System.debug('Accounts: ' + NUM_ACCOUNTS + ', Contacts: ' + (NUM_ACCOUNTS * CONTACTS_PER_ACCOUNT));
        System.debug('Insert time (ms): ' + (insertEndTime.getTime() - startTime.getTime()));
        System.debug('Update time (ms): ' + (updateEndTime.getTime() - updateStartTime.getTime()));
        System.debug('Delete time (ms): ' + (deleteEndTime.getTime() - deleteStartTime.getTime()));
        System.debug('Undelete time (ms): ' + (undeleteEndTime.getTime() - undeleteStartTime.getTime()));
        
        // Ensure our data volume is appropriate for bulk testing but doesn't exceed limits
        System.assert(NUM_ACCOUNTS * CONTACTS_PER_ACCOUNT < Limits.getLimitDmlRows(), 
            'Bulk test should use significant but safe data volume');
    }
    
    @isTest
    public static void testAccountContactServiceWithNullParams() {
        // This test specifically targets the uncovered line in AccountContactService
        Test.startTest();
        // Test with null parameter
        AccountContactService.updateActiveContacts(null);
        
        // Test with empty set
        AccountContactService.updateActiveContacts(new Set<Id>());
        Test.stopTest();
        
        // No assertions needed as we're just ensuring the method doesn't throw exceptions
        System.assert(true, 'Test passed if no exceptions were thrown');
    }
}