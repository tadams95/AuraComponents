@isTest
private class CaseCommentHandlerTest {
    
    @isTest
    static void testUpdateDescriptionOnOtherCases() {
        // Setup test data
        List<Case> testCases = new List<Case>();
        for(Integer i = 0; i < 5; i++) {
            testCases.add(new Case(
                Subject = 'Test Case ' + i,
                Reason = 'Other'
            ));
        }
        
        // Also create a case with different reason
        testCases.add(new Case(
            Subject = 'Test Case Non-Other',
            Reason = 'Installation'
        ));
        
        insert testCases;
        
        // Execute test
        Test.startTest();
        Integer updatedCount = CaseCommentHandler.updateDescriptionOnOtherCases();
        Test.stopTest();
        
        // Verify results
        List<Case> updatedCases = [
            SELECT Id, Description, Reason 
            FROM Case 
            WHERE Reason = 'Other'
        ];
        
        List<Case> nonUpdatedCases = [
            SELECT Id, Description, Reason 
            FROM Case 
            WHERE Reason != 'Other'
        ];
        
        System.assertEquals(5, updatedCount, 'Should have updated 5 cases');
        System.assertEquals(5, updatedCases.size(), 'Should have 5 updated cases in the database');
        System.assertEquals(1, nonUpdatedCases.size(), 'Should have 1 non-updated case in the database');
        
        for(Case c : updatedCases) {
            System.assertEquals('Further evaluation required', c.Description, 'Description field should match');
        }
        
        for(Case c : nonUpdatedCases) {
            System.assertNotEquals('Further evaluation required', c.Description, 'Description field should not be updated');
        }
    }
    
    @isTest
    static void testUpdateDescriptionOnCases() {
        // Setup test data
        List<Case> testCases = new List<Case>();
        for(Integer i = 0; i < 3; i++) {
            testCases.add(new Case(
                Subject = 'Test Case ' + i
            ));
        }
        
        insert testCases;
        
        // Execute test
        Test.startTest();
        Integer updatedCount = CaseCommentHandler.updateDescriptionOnCases(
            testCases, 
            'Custom description text'
        );
        Test.stopTest();
        
        // Verify results
        List<Case> updatedCases = [
            SELECT Id, Description 
            FROM Case 
            WHERE Id IN :testCases
        ];
        
        System.assertEquals(3, updatedCount, 'Should have updated 3 cases');
        System.assertEquals(3, updatedCases.size(), 'Should have 3 updated cases in the database');
        
        for(Case c : updatedCases) {
            System.assertEquals('Custom description text', c.Description, 'Description field should match');
        }
    }
    
    @isTest
    static void testNoDescriptionUpdated() {
        // Setup - no cases to update
        List<Case> emptyCaseList = new List<Case>();
        
        // Execute test
        Test.startTest();
        Integer updatedCount = CaseCommentHandler.updateDescriptionOnCases(
            emptyCaseList, 
            'Test description'
        );
        Test.stopTest();
        
        // Verify results
        System.assertEquals(0, updatedCount, 'Should return 0 when no cases are updated');
    }
    
    @isTest
    static void testUpdateDescriptionOnBreakdownCases() {
        // Setup test data
        List<Case> testCases = new List<Case>();
        
        // Cases that should be updated
        for(Integer i = 0; i < 3; i++) {
            testCases.add(new Case(
                Subject = 'Breakdown Case ' + i,
                Reason = 'Breakdown',
                Status = 'Working'
            ));
        }
        
        // Cases with right reason but wrong status
        testCases.add(new Case(
            Subject = 'Breakdown Case Wrong Status',
            Reason = 'Breakdown',
            Status = 'New'
        ));
        
        // Cases with right status but wrong reason
        testCases.add(new Case(
            Subject = 'Wrong Reason Case',
            Reason = 'Other',
            Status = 'Working'
        ));
        
        insert testCases;
        
        // Execute test
        Test.startTest();
        Integer updatedCount = CaseCommentHandler.updateDescriptionOnBreakdownCases();
        Test.stopTest();
        
        // Verify results
        List<Case> updatedCases = [
            SELECT Id, Description, Reason, Status 
            FROM Case 
            WHERE Reason = 'Breakdown' AND Status = 'Working'
        ];
        
        List<Case> nonUpdatedCases = [
            SELECT Id, Description, Reason, Status 
            FROM Case 
            WHERE (Reason = 'Breakdown' AND Status != 'Working') 
               OR (Reason != 'Breakdown' AND Status = 'Working')
        ];
        
        System.assertEquals(3, updatedCount, 'Should have updated 3 cases');
        System.assertEquals(3, updatedCases.size(), 'Should have 3 updated cases in the database');
        System.assertEquals(2, nonUpdatedCases.size(), 'Should have 2 non-updated cases in the database');
        
        for(Case c : updatedCases) {
            System.assertEquals('In-Progress', c.Description, 'Description field should match');
        }
        
        for(Case c : nonUpdatedCases) {
            System.assertNotEquals('In-Progress', c.Description, 'Description field should not be updated');
        }
    }
}
