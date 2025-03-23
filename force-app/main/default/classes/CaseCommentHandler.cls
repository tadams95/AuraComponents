public class CaseCommentHandler {
    
    /**
     * Updates the Description field for all Cases with Reason = 'Other'
     * @return Number of Cases successfully updated
     */
    public static Integer updateDescriptionOnOtherCases() {
        return updateDescriptionOnOtherCases('Further evaluation required');
    }
    
    /**
     * Updates the Description field for all Cases with Reason = 'Other'
     * @param descriptionText The text to set as Description
     * @return Number of Cases successfully updated
     */
    public static Integer updateDescriptionOnOtherCases(String descriptionText) {
        // Query cases with Reason = 'Other'
        List<Case> casesWithOtherReason = [
            SELECT Id, Description, Reason 
            FROM Case 
            WHERE Reason = 'Other'
        ];
        
        return updateDescriptionOnCases(casesWithOtherReason, descriptionText);
    }
    
    /**
     * Updates the Description field for all Cases with Reason = 'Breakdown' and Status = 'Working'
     * @return Number of Cases successfully updated
     */
    public static Integer updateDescriptionOnBreakdownCases() {
        return updateDescriptionOnBreakdownCases('In-Progress');
    }
    
    /**
     * Updates the Description field for all Cases with Reason = 'Breakdown' and Status = 'Working'
     * @param descriptionText The text to set as Description
     * @return Number of Cases successfully updated
     */
    public static Integer updateDescriptionOnBreakdownCases(String descriptionText) {
        // Query cases with Reason = 'Breakdown' and Status = 'Working'
        List<Case> breakdownCases = [
            SELECT Id, Description, Reason, Status 
            FROM Case 
            WHERE Reason = 'Breakdown' AND Status = 'Working'
        ];
        
        return updateDescriptionOnCases(breakdownCases, descriptionText);
    }
    
    /**
     * Updates the Description field for a list of Cases
     * @param casesToUpdate List of Cases to update
     * @param descriptionText The text to set as Description
     * @return Number of Cases successfully updated
     */
    public static Integer updateDescriptionOnCases(List<Case> casesToUpdate, String descriptionText) {
        List<Case> casesToSave = new List<Case>();
        
        for (Case c : casesToUpdate) {
            c.Description = descriptionText;
            casesToSave.add(c);
        }
        
        // Update the cases
        if (!casesToSave.isEmpty()) {
            try {
                update casesToSave;
                System.debug('Updated Description on ' + casesToSave.size() + ' cases');
                return casesToSave.size();
            } catch (Exception e) {
                System.debug('Error updating Description: ' + e.getMessage());
                throw new CaseCommentHandlerException('Failed to update Description: ' + e.getMessage());
            }
        }
        return 0;
    }
    
    /**
     * Custom exception class for CaseCommentHandler
     */
    public class CaseCommentHandlerException extends Exception {}
}