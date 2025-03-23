/**
 * @description Controller class for Opportunity related operations
 */
public class OpportunityController {

    /**
     * @description Updates the Profile__c field on Opportunities based on Amount
     * @param oppIds List of Opportunity Ids to update
     */
    public static void updateProfile(List<Id> oppIds) {
        // Query all opportunities at once to avoid SOQL query inside loop
        List<Opportunity> oppsToUpdate = [
            SELECT Id, Amount, Profile__c 
            FROM Opportunity 
            WHERE Id IN :oppIds
        ];
        
        for (Opportunity opp : oppsToUpdate) {
            if (opp.Amount == null || opp.Amount < 10000) {
                opp.Profile__c = 'Low';
            } else if (opp.Amount >= 10000 && opp.Amount < 50000) {
                opp.Profile__c = 'Medium';
            } else {
                opp.Profile__c = 'High';
            }
        }
        
        // Single DML statement outside the loop
        if (!oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
        }
    }
}