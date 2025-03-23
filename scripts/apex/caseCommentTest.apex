// Basic usage - update Comments on Cases with Reason = 'Other'
Integer casesUpdated = CaseCommentHandler.updateCommentsOnOtherCases();
System.debug('Updated Comments on ' + casesUpdated + ' cases with Reason = Other');

// Custom comment text
Integer customCasesUpdated = CaseCommentHandler.updateCommentsOnOtherCases(
    'Please provide additional details about this case'
);
System.debug('Updated Comments on ' + customCasesUpdated + ' cases with custom text');

// Update Comments on specific cases
List<Case> recentCases = [SELECT Id FROM Case WHERE CreatedDate = LAST_N_DAYS:7 LIMIT 10];
Integer recentCasesUpdated = CaseCommentHandler.updateCommentsOnCases(
    recentCases,
    'This case was created in the last week'
);
System.debug('Updated Comments on ' + recentCasesUpdated + ' recent cases');
