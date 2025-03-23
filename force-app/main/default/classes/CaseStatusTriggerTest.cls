@isTest
private class CaseStatusTriggerTest {
    
    @isTest
    static void testBreakdownCaseStatusChangedToWorking() {
        // Setup test data
        List<Case> testCases = new List<Case>();
        
        // Cases that will be updated to Working
        for(Integer i = 0; i < 3; i++) {
            testCases.add(new Case(
                Subject = 'Breakdown Case ' + i,
                Reason = 'Breakdown',
                Status = 'New'
            ));
        }
        
        // Cases with wrong reason
        testCases.add(new Case(
            Subject = 'Other Case',
            Reason = 'Other',
            Status = 'New'
        ));
        
        insert testCases;
        
        // Update the status to Working
        List<Case> casesToUpdate = new List<Case>();
        for(Case c : testCases) {
            c.Status = 'Working';
            casesToUpdate.add(c);
        }
        
        // Execute test
        Test.startTest();
        update casesToUpdate;
        Test.stopTest();
        
        // Verify results
        List<Case> breakdownCases = [
            SELECT Id, Description, Reason, Status 
            FROM Case 
            WHERE Reason = 'Breakdown'
        ];
        
        List<Case> otherReasonCases = [
            SELECT Id, Description, Reason, Status 
            FROM Case 
            WHERE Reason != 'Breakdown'
        ];
        
        System.assertEquals(3, breakdownCases.size(), 'Should have 3 Breakdown cases');
        System.assertEquals(1, otherReasonCases.size(), 'Should have 1 Other case');
        
        for(Case c : breakdownCases) {
            System.assertEquals('In-Progress', c.Description, 'Description field should be updated for Breakdown cases');
        }
        
        for(Case c : otherReasonCases) {
            System.assertNotEquals('In-Progress', c.Description, 'Description field should not be updated for non-Breakdown cases');
        }
    }
}
